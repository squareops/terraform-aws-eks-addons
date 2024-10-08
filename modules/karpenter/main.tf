
module "helm_addon" {
  depends_on        = [resource.aws_iam_instance_profile.karpenter_profile]
  source            = "../helm-addon"
  manage_via_gitops = var.manage_via_gitops
  helm_config       = local.helm_config
  set_values        = local.set_values
  irsa_config       = local.irsa_config
  addon_context     = var.addon_context
}

resource "aws_iam_policy" "karpenter" {
  name        = "${var.addon_context.eks_cluster_id}-karpenter"
  description = "IAM Policy for Karpenter"
  policy      = data.aws_iam_policy_document.karpenter.json
}

resource "aws_iam_policy" "karpenter-spot" {
  name        = "${var.addon_context.eks_cluster_id}-karpenter-spot"
  description = "IAM Policy for Karpenter"
  policy      = data.aws_iam_policy_document.karpenter-spot-service-linked-policy.json
}

resource "aws_iam_instance_profile" "karpenter_profile" {
  role        = var.worker_iam_role_name
  name_prefix = var.eks_cluster_name
  tags = merge(
    { "Name"        = format("%s-%s-karpenter-profile", "karpenter", "addon")
      "Environment" = "karpenter"
    }
  )
}
locals {
  node_iam_instance_profile = aws_iam_instance_profile.karpenter_profile.name
}
