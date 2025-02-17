variable "helm_config" {
  description = "Helm provider config for the Karpenter"
  type        = any
  default     = {}
}

variable "karpenter_helm_config" {
  description = "Helm provider config for the Karpenter"
  type        = any
  default     = {}
}

variable "irsa_policies" {
  description = "Additional IAM policies for a IAM role for service accounts"
  type        = list(string)
  default     = []
}

variable "manage_via_gitops" {
  description = "Determines if the add-on should be managed via GitOps."
  type        = bool
  default     = false
}

variable "node_iam_instance_profile" {
  description = "Karpenter Node IAM Instance profile id"
  default     = ""
  type        = string
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

variable "worker_iam_role_name" {
  description = "Specify the IAM role for the nodes that will be provisioned through karpenter"
  default     = ""
  type        = string
}

variable "eks_cluster_name" {
  description = "Fetch Cluster ID of the cluster"
  default     = ""
  type        = string
}

variable "kms_key_arn" {
  description = "Cluster kms key for encryption"
  type        = string
  default     = ""
}

variable "chart_version" {
  description = "Helm cart version for karpenter CRDs"
  type        = string
  default     = "1.2.1"
}

variable "enable_service_monitor" {
  description = "Specifies whether a ServiceMonitor should be created."
  type        = bool
  default     = false
}
