resource "helm_release" "vpa-crds" {
  name       = "vertical-pod-autoscaler"
  namespace  = "kube-system"
  repository = "https://cowboysysop.github.io/charts/"
  chart      = "vertical-pod-autoscaler"
  version    = var.chart_version
  timeout    = 600
  values = [
    file("${path.module}/config/values.yaml"),
    var.helm-config
  ]
}
