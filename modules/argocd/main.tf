locals {
  alb_scheme = var.argocd_config.private_alb_enabled ? "internal" : "internet-facing"
}

resource "helm_release" "argocd_deploy" {
  name       = "argo-cd"
  chart      = "argo-cd"
  timeout    = 600
  version    = var.chart_version
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  values = [
    templatefile("${path.module}/config/values.yaml", {
      hostname                  = var.argocd_config.hostname
      slack_token               = var.argocd_config.slack_notification_token
      redis_ha_enable           = var.argocd_config.redis_ha_enabled
      autoscaling_enabled       = var.argocd_config.autoscaling_enabled
      enable_argo_notifications = var.argocd_config.argocd_notifications_enabled
      ingress_class_name        = var.argocd_config.ingress_class_name

    }),
    var.argocd_config.values_yaml
  ]
}

data "kubernetes_secret" "argocd-secret" {
  depends_on = [helm_release.argocd_deploy]
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = var.namespace
  }
}

resource "kubernetes_ingress_v1" "argocd-ingress" {
  depends_on             = [helm_release.argocd_deploy]
  wait_for_load_balancer = true
  metadata {
    name      = "argocd-ingress"
    namespace = var.namespace
    annotations = var.argocd_config.argocd_ingress_load_balancer == "alb" ? {
      "kubernetes.io/ingress.class"                    = "alb"
      "alb.ingress.kubernetes.io/scheme"               = local.alb_scheme
      "alb.ingress.kubernetes.io/target-type"          = "ip"
      "alb.ingress.kubernetes.io/certificate-arn"      = var.argocd_config.alb_acm_certificate_arn,
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/healthz"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTP"
      "alb.ingress.kubernetes.io/backend-protocol"     = "HTTP"
      "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"         = "443"
      "alb.ingress.kubernetes.io/group.name"           = local.alb_scheme == "internet-facing" ? "public-alb-ingress" : "private-alb-ingress"
      } : {
      "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/ssl-passthrough"    = "true"
      "kubernetes.io/ingress.class"                    = var.argocd_config.ingress_class_name
      "kubernetes.io/tls-acme"                         = "false"
    }
  }
  spec {
    ingress_class_name = var.argocd_config.ingress_class_name
    rule {
      host = var.argocd_config.hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argo-cd-argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = var.argocd_config.argocd_ingress_load_balancer == "alb" ? "" : "argocd-server-tls"
      hosts       = var.argocd_config.argocd_ingress_load_balancer == "alb" ? [] : [var.argocd_config.hostname]
    }
  }
}
