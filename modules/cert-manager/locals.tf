locals {
  name            = "cert-manager"
  service_account = "cert-manager" # AWS PrivateCA is expecting the service account name as `cert-manager`

  # https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/Chart.template.yaml
  default_helm_config = {
    name       = local.name
    chart      = local.name
    repository = "https://charts.jetstack.io"
    version    = var.addon_version

    namespace   = local.name
    description = "Cert Manager Add-on"
    values      = local.default_helm_values
  }

  default_helm_values = templatefile("${path.module}/config/values.yaml", {
    enable_service_monitor = var.helm_config.enable_service_monitor
  })

  helm_config = merge(
    local.default_helm_config,
    var.helm_config,
    {
      values = [local.default_helm_values, var.helm_config.values[0]]
    }
  )

  set_values = concat(
    [
      {
        name  = "serviceAccount.name"
        value = local.service_account
      },
      {
        name  = "serviceAccount.create"
        value = false
      }
    ],
    try(var.helm_config.set_values, [])
  )

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account = true
    kubernetes_svc_image_pull_secrets = var.kubernetes_svc_image_pull_secrets
    irsa_iam_policies                 = concat([aws_iam_policy.cert_manager.arn], var.irsa_policies)
  }

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account
  }
}
