locals {
  name            = "cluster-proportional-autoscaler"
  namespace       = "kube-system"

  default_helm_values = [templatefile("${path.module}/config/values.yaml", {
    enable_service_monitor = var.enable_service_monitor
  })]

  default_helm_config = {
      name        = local.name
      chart       = local.name
      repository = "https://kubernetes-sigs.github.io/cluster-proportional-autoscaler"
      version     = "1.1.0"
      namespace   = local.namespace
      description = "Cluster Proportional Autoscaler Helm Chart"
      values      = local.default_helm_values
    }

    helm_config = merge(
      local.default_helm_config,
      var.helm_config,
      {
      values = concat(
        local.default_helm_values,          # Values from config folder
        var.helm_config.values              # Values from the variable
      )
    }
  )
}