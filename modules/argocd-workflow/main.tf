locals {
  alb_scheme    = var.argoworkflow_config.private_alb_enabled ? "internal" : "internet-facing"
  template_path = "${path.module}/config/argocd-workflow.yaml"

  # read modules template file
  template_values = templatefile("${path.module}/config/argocd-workflow.yaml", {
    ingress_host        = var.argoworkflow_config.hostname
    ingress_class_name  = var.argoworkflow_config.ingress_class_name
    autoscaling_enabled = var.argoworkflow_config.autoscaling_enabled
  })

}

resource "helm_release" "argo_workflow" {
  name       = "argo-workflow"
  chart      = "argo-workflows"
  timeout    = 600
  version    = var.chart_version
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  values     = [local.template_values, var.argoworkflow_config.values]
}

resource "kubernetes_service_account_v1" "argoworkflows-service-account" {
  metadata {
    name      = "argo-workflow"
    namespace = var.namespace
  }
}

resource "kubernetes_cluster_role" "argo_workflow_role" {
  metadata {
    name = "argo-workflow-role"
  }

  rule {
    api_groups = [""]
    resources  = ["pods", "pods/log", "services", "configmaps", "secrets"]
    verbs      = ["get", "list", "watch"]
  }
  rule {
    api_groups = ["argoproj.io"]
    resources  = ["*"]
    verbs      = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "argo_workflow_binding" {
  metadata {
    name = "argo-workflow-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.argo_workflow_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.argoworkflows-service-account.metadata[0].name
    namespace = var.namespace
  }
}

data "kubernetes_secret" "argo-workflow-secret" {
  depends_on = [helm_release.argo_workflow]
  metadata {
    name      = "argo-workflow-initial-admin-secret"
    namespace = var.namespace
  }
}

resource "kubernetes_secret" "argo_workflow_token_secret" {
  metadata {
    name      = "argo-workflow-token"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.argoworkflows-service-account.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"
  data = {
    # Use 'try' to attempt accessing the token and handle cases where the secret isn't available yet
    token = try(data.kubernetes_secret.argo-workflow-secret.data["token"], "")
  }
}

resource "kubernetes_ingress_v1" "argoworkflow-ingress" {
  depends_on             = [helm_release.argo_workflow]
  wait_for_load_balancer = true
  metadata {
    name      = "argoworkflow-ingress"
    namespace = var.namespace
    annotations = var.argoworkflow_config.argoworkflow_ingress_load_balancer == "alb" ? {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/scheme"               = local.alb_scheme
      "alb.ingress.kubernetes.io/target-type"          = "ip"
      "alb.ingress.kubernetes.io/certificate-arn"      = var.argoworkflow_config.alb_acm_certificate_arn,
      "alb.ingress.kubernetes.io/subnets"              = local.alb_scheme == "internal" ? join(",", var.private_subnet_ids) : join(",", var.public_subnet_ids)
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/backend-protocol"     = "HTTP"
      "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"         = "443"
      "alb.ingress.kubernetes.io/group.name"           = local.alb_scheme == "internet-facing" ? "public-alb-ingress" : "private-alb-ingress"
      } : {
      "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/ssl-passthrough"    = "true"
      "kubernetes.io/ingress.class"                    = var.argoworkflow_config.ingress_class_name
      "kubernetes.io/tls-acme"                         = "false"
    }
  }
  spec {
    ingress_class_name = var.argoworkflow_config.ingress_class_name
    rule {
      host = var.argoworkflow_config.hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argo-workflow-argo-workflows-server"
              port {
                number = 2746
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = var.argoworkflow_config.argoworkflow_ingress_load_balancer == "alb" ? "" : "argoworkflow-server-tls"
      hosts       = var.argoworkflow_config.argoworkflow_ingress_load_balancer == "alb" ? [] : [var.argoworkflow_config.hostname]
    }
  }
}