


resource "kubernetes_namespace" "internal_nginx" {
  metadata {
    name = "internal-ingress-nginx"
  }
}

resource "helm_release" "internal_nginx" {
  name       = "internal-ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.9.1"
  namespace  = "internal-ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
 # internal_nginx_values_yaml              = var.internal_nginx.internal_nginx_values_yaml
  values = [
    file("${path.module}/config/${var.ip_family == "ipv4" ? "ingress.yaml" : "ingress_ipv6.yaml"}"),
     var.internal_ingress_yaml_file
  ]
}

data "kubernetes_service" "internal-nginx-ingress" {
  depends_on = [helm_release.internal_nginx]
  count      = var.internal_ingress_nginx_enabled ? 1 : 0
  metadata {
    name      = "internal-ingress-nginx-controller"
    namespace = "internal-ingress-nginx"
  }
}