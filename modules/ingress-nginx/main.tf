locals {
  name      = try(var.helm_config.name, "ingress-nginx")
  namespace = try(var.helm_config.namespace, local.name)
}

data "kubernetes_service" "nginx-ingress" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

resource "kubernetes_namespace_v1" "this" {
  count = try(var.helm_config.create_namespace, true) && local.namespace != "kube-system" ? 1 : 0

  metadata {
    name = local.namespace
  }
}
module "helm_addon" {
  source = "../helm-addon"

  helm_config = merge(
    {
      name        = local.name
      chart       = local.name
      repository  = "https://kubernetes.github.io/ingress-nginx"
      version     = "4.10.1"
      namespace   = try(kubernetes_namespace_v1.this[0].metadata[0].name, local.namespace)
      description = "The NGINX HelmChart Ingress Controller deployment configuration"
      values = templatefile("${path.module}/config/${var.ip_family == "ipv4" ? "nginx_ingress.yaml" : "nginx_ingress_ipv6.yaml"}" , 
         {
         enable_service_monitor = var.enable_service_monitor
         })
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
