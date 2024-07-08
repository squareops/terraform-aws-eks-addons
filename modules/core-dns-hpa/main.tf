resource "helm_release" "coredns-hpa" {
  name                      = "corednshpa"
  namespace                 = "kube-system"
  chart                     = "${path.module}/config"
  timeout                   = 600
  values    = [
    "${path.root}/config/values.yaml",
    var.helm_config
  ]
}
