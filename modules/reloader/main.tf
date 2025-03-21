locals {
  name = "reloader"

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.name
  }

  template_values = templatefile("${path.module}/config/reloader.yaml", {
    enable_service_monitor = var.helm_config.enable_service_monitor
  })
}

module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/stakater/Reloader/blob/master/deployments/kubernetes/chart/reloader/Chart.yaml
  helm_config = merge(
    {
      name             = local.name
      chart            = local.name
      repository       = "https://stakater.github.io/stakater-charts"
      version          = var.addon_version
      namespace        = local.name
      create_namespace = true
      description      = "Reloader Helm Chart deployment configuration"
    },
    var.helm_config,
    {
      values = [local.template_values, var.helm_config.values[0]]
    }
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
