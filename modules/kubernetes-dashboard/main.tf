locals {
  alb_scheme = var.kubernetes_dashboard_config.private_alb_enabled ? "internal" : "internet-facing"
}

resource "kubernetes_namespace" "k8s-dashboard" {
  metadata {
    name = "kubernetes-dashboard"
  }
}

resource "helm_release" "kubernetes-dashboard" {
  depends_on = [kubernetes_namespace.k8s-dashboard]
  name       = "kubernetes-dashboard"
  namespace  = "kubernetes-dashboard"
  chart      = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  timeout    = 600
  version    = var.addon_version
  values = [
    templatefile("${path.module}/config/values.yaml", {
      hostname               = var.kubernetes_dashboard_config.k8s_dashboard_hostname
      ingress_class_name     = var.kubernetes_dashboard_config.ingress_class_name
      enable_service_monitor = var.kubernetes_dashboard_config.enable_service_monitor
    }),
    var.kubernetes_dashboard_config.values_yaml
  ]
}

resource "kubernetes_ingress_v1" "k8s-ingress" {
  depends_on             = [helm_release.kubernetes-dashboard]
  wait_for_load_balancer = true
  metadata {
    name      = "k8s-dashboard-ingress"
    namespace = "kubernetes-dashboard"
    annotations = var.kubernetes_dashboard_config.k8s_dashboard_ingress_load_balancer == "alb" ? {
      "kubernetes.io/ingress.class"                    = var.kubernetes_dashboard_config.ingress_class_name
      "alb.ingress.kubernetes.io/scheme"               = local.alb_scheme
      "alb.ingress.kubernetes.io/target-type"          = "ip"
      "alb.ingress.kubernetes.io/certificate-arn"      = var.kubernetes_dashboard_config.alb_acm_certificate_arn
      "alb.ingress.kubernetes.io/healthcheck-path"     = "/"
      "alb.ingress.kubernetes.io/healthcheck-protocol" = "HTTPS"
      "alb.ingress.kubernetes.io/backend-protocol"     = "HTTPS"
      "alb.ingress.kubernetes.io/listen-ports"         = "[{\"HTTPS\":443}]"
      "alb.ingress.kubernetes.io/ssl-redirect"         = "443"
      "alb.ingress.kubernetes.io/group.name"           = local.alb_scheme == "internet-facing" ? "public-alb-ingress" : "private-alb-ingress"
      "alb.ingress.kubernetes.io/subnets"              = join(",", var.kubernetes_dashboard_config.subnet_ids)
      } : {
      "cert-manager.io/cluster-issuer"                    = "letsencrypt-prod"
      "kubernetes.io/ingress.class"                       = var.kubernetes_dashboard_config.ingress_class_name
      "kubernetes.io/tls-acme"                            = "false"
      "nginx.ingress.kubernetes.io/backend-protocol"      = "HTTPS"
      "nginx.ingress.kubernetes.io/rewrite-target"        = "/$2"
      "nginx.ingress.kubernetes.io/configuration-snippet" = <<-EOF
        if ($uri = "/dashboard") {
          rewrite ^(/dashboard)$ $1/ redirect;
        }
      EOF
    }
  }
  spec {
    ingress_class_name = var.kubernetes_dashboard_config.ingress_class_name
    rule {
      host = var.kubernetes_dashboard_config.k8s_dashboard_hostname
      http {
        path {
          path = var.kubernetes_dashboard_config.k8s_dashboard_ingress_load_balancer == "alb" ? "/" : "/dashboard(/|$)(.*)"
          path_type = var.kubernetes_dashboard_config.k8s_dashboard_ingress_load_balancer == "alb" ? "Prefix" : "ImplementationSpecific"

          backend {
            service {
              name = "kubernetes-dashboard"
              port {
                number = 443
              }
            }
          }
        }
      }
    }
    tls {
      secret_name = var.kubernetes_dashboard_config.k8s_dashboard_ingress_load_balancer == "alb" ? "" : "tls-k8s-dashboard"
      hosts       = var.kubernetes_dashboard_config.k8s_dashboard_ingress_load_balancer == "alb" ? [] : [var.kubernetes_dashboard_config.k8s_dashboard_hostname]
    }
  }
}

resource "kubernetes_service_account" "dashboard_admin_sa" {
  depends_on = [helm_release.kubernetes-dashboard]
  metadata {
    name      = "kubernetes-dashboard-admin-sa"
    namespace = "kube-system"
  }
}

resource "kubernetes_secret_v1" "admin-user" {
  metadata {
    name      = "admin-user-token"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.dashboard_admin_sa.metadata[0].name
    }
  }
  type = "kubernetes.io/service-account-token"
  depends_on = [
    kubernetes_cluster_role_binding_v1.admin-user,
    kubernetes_service_account.dashboard_admin_sa
  ]
}

resource "kubernetes_cluster_role_binding_v1" "admin-user" {
  metadata {
    name = "admin-user"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dashboard_admin_sa.metadata[0].name
    namespace = "kube-system"
  }
  depends_on = [
    kubernetes_service_account.dashboard_admin_sa
  ]
}

resource "kubernetes_cluster_role" "eks_read_only_role" {
  metadata {
    name = "dashboard-viewonly"
  }

  rule {
    api_groups = [""]
    resources = [
      "configmaps",
      "endpoints",
      "persistentvolumeclaims",
      "pods",
      "replicationcontrollers",
      "replicationcontrollers/scale",
      "serviceaccounts",
      "services",
      "nodes",
      "persistentvolumes",
      "bindings",
      "events",
      "limitranges",
      "namespaces/status",
      "pods/log",
      "pods/status",
      "replicationcontrollers/status",
      "resourcequotas",
      "resourcequotas/status",
      "namespaces",
      "apps/daemonsets",
      "apps/deployments",
      "apps/deployments/scale",
      "apps/replicasets",
      "apps/replicasets/scale",
      "apps/statefulsets",
      "autoscaling/horizontalpodautoscalers",
      "batch/cronjobs",
      "batch/jobs",
      "extensions/daemonsets",
      "extensions/deployments",
      "extensions/deployments/scale",
      "extensions/ingresses",
      "extensions/networkpolicies",
      "extensions/replicasets",
      "extensions/replicasets/scale",
      "extensions/replicationcontrollers/scale",
      "policy/poddisruptionbudgets",
      "networking.k8s.io/networkpolicies",
      "storage.k8s.io/storageclasses",
      "storage.k8s.io/volumeattachments",
      "rbac.authorization.k8s.io/clusterrolebindings",
      "rbac.authorization.k8s.io/clusterroles",
      "rbac.authorization.k8s.io/roles",
      "rbac.authorization.k8s.io/rolebindings",
    ]
    verbs = ["get", "list", "watch"]
  }
}

# Add more rules as needed for read-only access to other Kubernetes resources

resource "kubernetes_service_account" "dashboard_read_only_sa" {
  metadata {
    name      = "dashboard-read-only-sa"
    namespace = "kube-system"
  }
}

resource "kubernetes_cluster_role_binding" "eks_read_only_role_binding" {
  metadata {
    name = "eks-read-only-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.eks_read_only_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.dashboard_read_only_sa.metadata[0].name
    namespace = "kube-system"
  }

  depends_on = [
    kubernetes_cluster_role.eks_read_only_role,
    kubernetes_service_account.dashboard_read_only_sa
  ]
}

resource "kubernetes_secret_v1" "dashboard_read_only_sa_token" {
  metadata {
    name      = "dashboard-read-only-sa-token"
    namespace = "kube-system"
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account.dashboard_read_only_sa.metadata[0].name
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [
    kubernetes_service_account.dashboard_read_only_sa,
    kubernetes_cluster_role_binding.eks_read_only_role_binding
  ]
}
