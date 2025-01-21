resource "kubernetes_namespace" "falco" {
  count = var.falco_enabled ? 1 : 0
  metadata {
    name = "falco"
  }
}

resource "helm_release" "falco" {
  count      = var.falco_enabled ? 1 : 0
  depends_on = [kubernetes_namespace.falco]
  name       = "falco"
  namespace  = "falco"
  chart      = "falco"
  repository = "https://falcosecurity.github.io/charts"
  timeout    = 600
  version    = var.version
  values = [
    templatefile("${path.module}/values.yaml", {
      slack_webhook = var.slack_webhook
    })
  ]
}
