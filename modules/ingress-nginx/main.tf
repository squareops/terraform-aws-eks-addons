locals {
  name      = var.enable_private_nlb ? "internal-ingress-nginx" : try(var.helm_config.name, "ingress-nginx")
  namespace = try(var.helm_config.namespace, local.name)
  nlb_scheme = var.enable_private_nlb ? "internal" : "internet-facing"
  template_path = "${path.module}/config/${var.ip_family == "ipv4" ? "ingress_nginx.yaml" : "ingress_nginx_ipv6.yaml"}"

  # Read module's template file
  template_values = templatefile(local.template_path, {
    enable_service_monitor = var.enable_service_monitor
    enable_private_nlb = var.enable_private_nlb
    nlb_scheme = local.nlb_scheme
    ingress_class_resource_name = var.ingress_class_resource_name
  })

  # Convert the template values to a map
  template_values_map = yamldecode(local.template_values)
}

# Namespace creation

resource "kubernetes_namespace_v1" "this" {
  count = try(var.helm_config.create_namespace, true) && local.namespace != "kube-system" && var.enable_private_nlb != true ? 1 : 0
  metadata {
    name = local.namespace
  }
}

resource "kubernetes_namespace" "internal_nginx" {
  count = local.namespace != "kube-system" && local.namespace != "ingress-nginx" ? 1 : 0
  metadata {
    name = "internal-ingress-nginx"
  }
}

# Service creation
data "kubernetes_service" "nginx-ingress" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

data "kubernetes_service" "internal-nginx-ingress" {
  count = var.enable_private_nlb ? 1 : 0
  metadata {
    name      = "internal-ingress-nginx-controller"
    namespace = "internal-ingress-nginx"
  }
}

module "helm_addon" {
  source = "../helm-addon"
  helm_config = merge(
    {
      name        = local.name
      chart       = "ingress-nginx"
      repository  = "https://kubernetes.github.io/ingress-nginx"
      version     = "4.11.0"
      namespace   = var.enable_private_nlb ? "internal-ingress-nginx" : try(kubernetes_namespace_v1.this[0].metadata[0].name, local.namespace)
      description = "The NGINX HelmChart Ingress Controller deployment configuration"
      values = [yamlencode(merge(local.template_values_map, var.helm_config))]
    }
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}