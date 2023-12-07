resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio_base" {
  depends_on = [kubernetes_namespace.istio_system]
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"
  namespace  = "istio-system"
  timeout    = 600
  version    = "1.18.0"
}

resource "helm_release" "istiod" {
  depends_on = [helm_release.istio_base]

  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"
  namespace  = "istio-system"
  timeout    = 600
  version    = "1.18.0"
  values = [
    file("${path.module}/helm/values/istiod/values.yaml"),
    var.istio_values_yaml
  ]
}

resource "kubernetes_namespace" "istio_ingress" {

  depends_on = [helm_release.istiod]
  count      = var.ingress_gateway_enabled ? 1 : 0

  metadata {
    name = var.ingress_gateway_namespace
  }

}

resource "helm_release" "istio_ingress" {
  depends_on = [helm_release.istiod, kubernetes_namespace.istio_ingress]
  count      = var.ingress_gateway_enabled ? 1 : 0
  name       = "istio-ingressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"
  namespace  = var.ingress_gateway_namespace
  timeout    = 600
  version    = "1.18.0"
  values = [
    file("${path.module}/helm/values.yaml")
  ]

  set {
    name  = "labels.app"
    value = "istio-ingressgateway"
  }

  set {
    name  = "labels.istio"
    value = "ingressgateway"
  }

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

}
