
locals {
  name                   = "karpenter"
  service_account        = try(var.helm_config.service_account, "karpenter")
  node_module_profile_id = resource.aws_iam_instance_profile.karpenter_profile.name
  set_values = [{
    name  = "serviceAccount.name"
    value = local.service_account
    },
    {
      name  = "serviceAccount.create"
      value = false
    }
  ]

  # https://github.com/aws/karpenter/blob/main/charts/karpenter/Chart.yaml
  helm_config = merge(
    {
      name       = local.name
      chart      = local.name
      repository = "oci://public.ecr.aws/karpenter"
      version    = "v0.32.10"
      namespace  = local.name
      values = [
        <<-EOT
          clusterName: ${var.addon_context.eks_cluster_id}
          clusterEndpoint: ${var.addon_context.aws_eks_cluster_endpoint}
          aws:
            defaultInstanceProfile: ${local.node_iam_instance_profile}
        EOT
        ,
        templatefile("${path.module}/config/karpenter.yaml", {
          eks_cluster_id            = var.addon_context.eks_cluster_id,
          eks_cluster_endpoint      = var.addon_context.aws_eks_cluster_endpoint,
          node_iam_instance_profile = local.node_module_profile_id # enter profile name for kubernetes iam profile
        })
      ]
      description = "karpenter Helm Chart for Node Autoscaling"
    },
    var.karpenter_helm_config
  )

  irsa_config = {
    kubernetes_namespace              = local.helm_config["namespace"]
    kubernetes_service_account        = local.service_account
    create_kubernetes_namespace       = try(local.helm_config["create_namespace"], true)
    create_kubernetes_service_account = true
    irsa_iam_policies                 = concat([aws_iam_policy.karpenter.arn], var.irsa_policies)
  }

  argocd_gitops_config = {
    enable                    = true
    serviceAccountName        = local.service_account
    controllerClusterEndpoint = var.addon_context.aws_eks_cluster_endpoint
    awsDefaultInstanceProfile = var.node_iam_instance_profile
  }
}