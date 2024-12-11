variable "namespace" {
  type        = string
  default     = "argocd"
  description = "Name of the Kubernetes namespace where the Argocd deployment will be deployed."
}

variable "argorollout_host" {
  type        = string
  description = "Define the host for argo workflow server"
  default     = ""
}

variable "argorollout_config" {
  type = any

  default = {
    values              = {}
    namespace           = ""
    hostname            = ""
  }
  description = "Specify the configuration settings for Argocd-Rollout, including the hostname, and custom YAML values."
}

variable "chart_version" {
  default     = "2.38.0"
  type        = string
  description = "Argo rollout chart version"
}
