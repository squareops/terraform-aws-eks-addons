variable "eks_cluster_version" {
  description = "The Kubernetes version for the cluster - used to match appropriate version for image used"
  type        = string
}

variable "helm_config" {
  description = "Cluster Autoscaler Helm Config"
  type        = any
  default     = {}
}

variable "manage_via_gitops" {
  description = "Determines if the add-on should be managed via GitOps."
  type        = bool
  default     = false
}

variable "addon_context" {
  description = "Input configuration for the addon"
  type = object({
    aws_caller_identity_account_id = string
    aws_caller_identity_arn        = string
    aws_eks_cluster_endpoint       = string
    aws_partition_id               = string
    aws_region_name                = string
    eks_cluster_id                 = string
    eks_oidc_issuer_url            = string
    eks_oidc_provider_arn          = string
    tags                           = map(string)
    irsa_iam_role_path             = string
    irsa_iam_permissions_boundary  = string
  })
}

variable "addon_version" {
  description = "Helm chart version of cluster autoscaler"
  type        = string
  default     = "9.46.3"
}
