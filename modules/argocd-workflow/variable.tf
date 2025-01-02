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
    values                             = {}
    namespace                          = ""
    hostname                           = ""
    autoscaling_enabled                = "true"
    ingress_class_name                 = ""
    argoworkflow_ingress_load_balancer = "nlb"
    private_alb_enabled                = false
    alb_acm_certificate_arn            = ""
  }
  description = "Specify the configuration settings for Argocd-Workflow, including the hostname, and custom YAML values."
}

variable "chart_version" {
  default     = "0.29.2"
  type        = string
  description = "Argo workflow chart version"
}
variable "ingress_class_name" {
  type        = string
  default     = "nginx"
  description = "Enter ingress class name which is created in EKS cluster"
}
