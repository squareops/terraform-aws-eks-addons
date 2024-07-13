locals {
  name = "reloader"

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.name
  }
}

module "helm_addon" {
  source = "../helm-addon"

  # https://github.com/stakater/Reloader/blob/master/deployments/kubernetes/chart/reloader/Chart.yaml
  helm_config = merge(
    {
      name             = local.name
      chart            = local.name
      repository       = "https://stakater.github.io/stakater-charts"
      version          = "v1.0.115"
      namespace        = local.name
      create_namespace = true
      description      = "Reloader Helm Chart deployment configuration"
    },
    {
      values = templatefile("${path.module}/config/reloader.yaml",
        {
          enable_service_monitor = var.helm_config.enable_service_monitor
      })
    },
    var.helm_config
  )

  manage_via_gitops = var.manage_via_gitops
  addon_context     = var.addon_context
}
