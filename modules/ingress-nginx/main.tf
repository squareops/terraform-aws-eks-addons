########################### PUBLIC NLB (Ingress nginx) ############################

locals {
  name      = try(var.helm_config.name, "ingress-nginx")
  namespace = try(var.helm_config.namespace, local.name)
}

data "kubernetes_service" "nginx-ingress" {
  count = var.enable_public_nlb ? 1 : 0
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

resource "kubernetes_namespace_v1" "this" {
  count = try(var.helm_config.create_namespace, true) && var.enable_public_nlb && local.namespace != "kube-system" ? 1 : 0

  metadata {
    name = local.namespace
  }
}
module "helm_addon" {
  count = var.enable_public_nlb ? 1 : 0
  source = "../helm-addon"
  helm_config = merge(
    {
      name        = local.name
      chart       = local.name
      repository  = "https://kubernetes.github.io/ingress-nginx"
      version     = "4.10.1"
      namespace   = try(kubernetes_namespace_v1.this[0].metadata[0].name, local.namespace)
      description = "The NGINX HelmChart Ingress Controller deployment configuration"
      values = templatefile("${path.module}/config/${var.ip_family == "ipv4" ? "ingress_nginx.yaml" : "ingress_nginx_ipv6.yaml"}" , 
         {
         enable_service_monitor = var.enable_service_monitor
         })
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}




########################### PRIVATE NLB (Internal ingress nginx) ############################

resource "kubernetes_namespace" "internal_nginx" {
  count = var.enable_public_nlb ? 0 : 1
  metadata {
    name = "internal-ingress-nginx"
  }
}
data "kubernetes_service" "internal-nginx-ingress" {
  depends_on = [helm_release.internal_nginx]
  count = var.enable_public_nlb ? 0 : 1
  metadata {
    name      = "internal-ingress-nginx-controller"
    namespace = "internal-ingress-nginx"
  }
}
resource "helm_release" "internal_nginx" {
  count = var.enable_public_nlb ? 0 : 1
  depends_on = [kubernetes_namespace.internal_nginx]
  name       = "internal-ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.1"
  namespace  = "internal-ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  values = [
    templatefile("${path.module}/config/${var.ip_family == "ipv4" ? "private_ingress.yaml" : "private_ingress_ipv6.yaml"}" , 
      { 
        enable_service_monitor = var.enable_service_monitor 
      }),
     var.internal_ingress_config
  ]
}

