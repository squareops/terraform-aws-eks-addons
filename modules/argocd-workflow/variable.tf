variable "namespace" {
  type        = string
  default     = "argocd"
  description = "Name of the Kubernetes namespace where the Argocd deployment will be deployed."
}

variable "argoworkflow_host" {
  type        = string
  description = "Define the host for argo workflow server"
  default     = ""
}

variable "argoworkflow_config" { 
  type = any

  default = {
    values = {}
    namespace = ""
    hostname = ""
  }
  description = "Specify the configuration settings for Argocd-Workflow, including the hostname, and custom YAML values."
}