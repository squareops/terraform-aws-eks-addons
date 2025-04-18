locals {
  name            = "keda"
  service_account = try(var.helm_config.service_account, "keda-operator-sa")

  # https://github.com/kedacore/charts/blob/main/keda/Chart.yaml
  helm_config = merge(
    {
      name        = local.name
      chart       = local.name
      repository  = "https://kedacore.github.io/charts"
      version     = var.addon_version
      namespace   = local.name
      description = "Keda Event-based autoscaler for workloads on Kubernetes"
      values      = [file("${path.module}/config/values.yaml"), var.helm_config.values[0]]
    }
  )

  set_values = [
    {
      name  = "serviceAccount.name"
      value = local.service_account
    },
    {
      name  = "serviceAccount.create"
      value = false
    }
  ]

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account = true
    irsa_iam_policies                 = concat([aws_iam_policy.keda_irsa.arn], var.irsa_policies)
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account
  }
}
