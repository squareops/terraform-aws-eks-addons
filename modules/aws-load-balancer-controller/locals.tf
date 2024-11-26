locals {
  name            = var.load_balancer_controller_name
  service_account = try(var.helm_config.service_account, "${local.name}-sa")
  namespace       = var.namespace
  # https://github.com/aws/eks-charts/blob/master/stable/aws-load-balancer-controller/Chart.yaml
  default_helm_config = {
    name             = var.load_balancer_controller_name
    namespace        = var.namespace
    create_namespace = true
    chart            = "aws-load-balancer-controller"
    repository       = "https://aws.github.io/eks-charts"
    version          = "1.8.1"
    values           = [yamlencode(merge(local.default_helm_values_map, local.helm_config_map))]
    description      = "aws-load-balancer-controller Helm Chart for ingress resources"
  }

  helm_config = merge(
    local.default_helm_config
  )

  # Decode and merge helm_config safely
  helm_config_map = length(var.helm_config) > 0 && can(yamldecode(var.helm_config[0])) ? yamldecode(var.helm_config[0]) : {
    affinity  = {}
    resources = {}
  }

  default_helm_values = [templatefile("${path.module}/config/values.yaml", {
    aws_region                    = var.addon_context.aws_region_name,
    eks_cluster_id                = var.addon_context.eks_cluster_id,
    repository                    = "${var.addon_context.default_repository}/amazon/aws-load-balancer-controller"
    load_balancer_controller_name = var.load_balancer_controller_name
    sa_name                       = local.service_account
    namespace                     = var.namespace
  })]

  default_helm_values_map = yamldecode(local.default_helm_values[0])

  set_values = concat(
    [
      {
        name  = "serviceAccount.name"
        value = local.service_account
      },
      {
        name  = "serviceAccount.create"
        value = false
      },
      {
        name  = "clusterName"
        value = var.addon_context.eks_cluster_id
      }
    ],
    try(var.helm_config.set_values, [])
  )

  argocd_gitops_config = {
    enable             = true
    serviceAccountName = local.service_account
  }

  irsa_config = {
    namespace                         = local.namespace
    kubernetes_namespace              = local.namespace
    kubernetes_service_account        = local.service_account
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account = true
    irsa_iam_policies                 = [aws_iam_policy.aws_load_balancer_controller.arn]
  }
}
