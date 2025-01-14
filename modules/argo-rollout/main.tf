locals {
  template_path = "${path.module}/config/argo-rollout.yaml"
  alb_scheme    = var.argorollout_config.private_alb_enabled ? "internal" : "internet-facing"

  # read modules template file
  template_values = templatefile("${path.module}/config/argo-rollout.yaml", {
    ingress_host                 = var.argorollout_config.hostname
    ingress_class_name           = var.argorollout_config.ingress_class_name
    enable_argorollout_dashboard = var.argorollout_config.enable_dashboard
  })

}

resource "helm_release" "argo_rollout" {
  name       = "argo-rollouts"
  chart      = "argo-rollouts"
  timeout    = 600
  version    = var.chart_version
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  values     = [local.template_values, var.argorollout_config.values]
}

# Generate random password
resource "random_password" "argorollout_password" {
  count            = var.argorollout_config.enable_dashboard == true && var.argorollout_config.argorollout_ingress_load_balancer == "nlb" ? 1 : 0
  length           = 16
  special          = true
  override_special = "_@"
}

resource "kubernetes_secret" "basic_auth_argo_rollout" {
  depends_on = [random_password.argorollout_password]
  count      = var.argorollout_config.enable_dashboard == true && var.argorollout_config.argorollout_ingress_load_balancer == "nlb" ? 1 : 0
  metadata {
    name      = "rollout-basic-auth"
    namespace = var.namespace
  }
  data = {
    auth = "admin:${bcrypt(random_password.argorollout_password[0].result)}"
  }
}

resource "kubernetes_ingress_v1" "argorollout-ingress" {
  count                  = var.argorollout_config.enable_dashboard == true ? 1 : 0
  depends_on             = [helm_release.argo_rollout, kubernetes_secret.basic_auth_argo_rollout]
  wait_for_load_balancer = true
  metadata {
    name      = "argo-rollouts-dashboard"
    namespace = var.namespace
    annotations = var.argorollout_config.argorollout_ingress_load_balancer == "alb" ? {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/scheme"               = local.alb_scheme
      "alb.ingress.kubernetes.io/target-type"          = "ip"
      "alb.ingress.kubernetes.io/certificate-arn"      = var.argorollout_config.alb_acm_certificate_arn,
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/rollouts"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/backend-protocol"     = "HTTP"
      "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"         = "443"
      "alb.ingress.kubernetes.io/group.name"           = local.alb_scheme == "internet-facing" ? "public-alb-ingress" : "private-alb-ingress"
      "alb.ingress.kubernetes.io/subnets"              = join(",", var.argorollout_config.subnet_ids)
      } : {
      "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/ssl-passthrough"    = "true"
      "kubernetes.io/ingress.class"                    = var.argorollout_config.ingress_class_name
      "kubernetes.io/tls-acme"                         = "false"
      "nginx.ingress.kubernetes.io/auth-type"          = "basic"
      "nginx.ingress.kubernetes.io/auth-secret"        = "${var.namespace}/rollout-basic-auth"
      "nginx.ingress.kubernetes.io/auth-realm"         = "Authentication Required - Please log in"
    }
  }
  spec {
    ingress_class_name = var.argorollout_config.ingress_class_name
    rule {
      host = var.argorollout_config.hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argo-rollouts-dashboard"
              port {
                number = 3100
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = var.argorollout_config.argorollout_ingress_load_balancer == "alb" ? "" : "argo-rollout-token"
      hosts       = var.argorollout_config.argorollout_ingress_load_balancer == "alb" ? [] : [var.argorollout_config.hostname]
    }
  }
}
