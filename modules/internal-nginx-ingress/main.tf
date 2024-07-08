


resource "kubernetes_namespace" "internal_nginx" {
  metadata {
    name = "internal-ingress-nginx"
  }
}
resource "helm_release" "internal_nginx" {
  depends_on = [kubernetes_namespace.internal_nginx]
  name       = "internal-ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.1"
  namespace  = "internal-ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
 # internal_nginx_values_yaml              = var.internal_nginx.internal_nginx_values_yaml
  values = [
    templatefile("${path.module}/config/${var.ip_family == "ipv4" ? "ingress.yaml" : "ingress_ipv6.yaml"}" , 
      { 
        enable_service_monitor = var.enable_service_monitor 
      }),
     var.internal_ingress_config
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