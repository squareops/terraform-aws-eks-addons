locals {
  template_path = "${path.module}/config/argocd-workflow.yaml"

  # read modules template file
  template_values = templatefile("${path.module}/config/argocd-workflow.yaml", {
    ingress_host = var.argoworkflow_config.hostname
    ingress_class_name = var.argoworkflow_config.ingress_class_name
    })

  # Convert the template values to a map
  template_values_map = yamldecode(local.template_values)

  # External values file
  external_values_map = yamldecode(var.argoworkflow_config.values)
}

resource "helm_release" "argo_workflow" {
  name       = "argo-workflow"
  chart      = "argo-workflows"
  timeout    = 600
  version    = "0.29.2"
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  values = [yamlencode(merge(local.template_values_map, local.external_values_map))]
}

resource "kubernetes_service_account_v1" "argoworkflows-service-account" {
  metadata {
    name = "argo-workflow"
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
    resources  = ["workflows"]
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


resource "kubernetes_ingress_v1" "argo_workflow_ingress" {
  metadata {
    name      = "argo-workflow-argo-workflows-server"
    namespace = var.namespace
  }

  spec {
    ingress_class_name = var.argoworkflow_config.ingress_class_name

    rule {
      host = var.argoworkflow_config.hostname

      http {
        path {
          path     = "/"
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
      hosts = [var.argoworkflow_config.hostname]
      secret_name = data.kubernetes_secret.argo-workflow-secret.metadata[0].name
    }
  }
}

