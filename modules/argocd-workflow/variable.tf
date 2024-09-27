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
    autoscaling_enabled = "true"
  }
  description = "Specify the configuration settings for Argocd-Workflow, including the hostname, and custom YAML values."
}

variable "chart_version" {
  default = "0.29.2"
  type = string
  description = "Argo workflow chart version"
}