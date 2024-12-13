locals {
  template_path = "${path.module}/config/argo-rollout.yaml"

  # read modules template file
  template_values = templatefile("${path.module}/config/argo-rollout.yaml", {
    ingress_host        = var.argorollout_config.hostname
    ingress_class_name  = var.argorollout_config.ingress_class_name
    enable_argoworkflow_dashboard = var.argorollout_config.enable_dashboard
  })

}

resource "helm_release" "argo_rollout" {
  name       = "argo-rollouts"
  chart      = "argo-rollouts"
  timeout    = 600
  version    = var.chart_version
  namespace  = var.namespace
  repository = "https://argoproj.github.io/argo-helm"
  values     = [local.template_values, var.argorollout_config.values]
}
