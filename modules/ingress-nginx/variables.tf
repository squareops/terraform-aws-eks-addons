################## Variables for public ingress nginx ##################
variable "helm_config" {
  description = "Ingress NGINX Helm Configuration"
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
  })
}

variable "ingress_nginx_enabled" {
  description = "Enable or disable Nginx Ingress Controller add-on for routing external traffic to Kubernetes services."
  default     = false
  type        = bool
}

variable "enable_service_monitor" {
  description = "Enable or disable Service Monitor add-on for monitoring Kubernetes services."
  default     = false
  type        = bool
}
variable "ip_family" {
  description = "ip family ipv4 and ipv6"
  type = string
  default = "ipv4"
}


################## Variables for private ingress nginx ##################

variable "internal_ingress_nginx_enabled" {
  description = "Enable or disable the deployment of an internal ingress controller for Kubernetes."
  default     = false
  type        = bool
}

variable "service_monitor_crd_enabled" {
  description = "Enable or disable the installation of Custom Resource Definitions (CRDs) for Prometheus Service Monitor. "
  default     = false
  type        = bool
}

variable "internal_ingress_config" {
  description = "values file from outside the module"
  default =  ""
  type = any
}

##### Control variable for public and private type of ingress nginx 

variable "enable_public_nlb" {
  description = "Control wheather to install public nlb or private nlb. Default is private"
  type = bool
  default = false
}
