resource "null_resource" "patch_karpenter_crds" {
  triggers = {
    karpenter_version = var.chart_version
  }

  provisioner "local-exec" {
    command = <<EOT
      chmod +x ${path.module}/scripts/patch_karpenter_crds.sh
      bash ${path.module}/scripts/patch_karpenter_crds.sh
    EOT
  }
}

resource "helm_release" "karpenter_crd" {
  depends_on  = [resource.null_resource.patch_karpenter_crds] # <-- Ensures order
  name        = "karpenter-crd"
  repository  = "oci://public.ecr.aws/karpenter"
  chart       = "karpenter-crd"
  version     = var.chart_version # Ensure this is the correct version
  description = "Karpenter CRDs"
  set {
    name  = "preDeleteHook"
    value = "true"
  }
}

module "helm_addon" {
  depends_on        = [resource.aws_iam_instance_profile.karpenter_profile, helm_release.karpenter_crd]
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
