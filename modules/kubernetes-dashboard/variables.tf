variable "k8s_dashboard_ingress_load_balancer" {
  description = "Controls whether to enable ALB Ingress or not."
  type        = string
  default     = "nlb"
}

variable "alb_acm_certificate_arn" {
  description = "ARN of the ACM certificate to be used for ALB Ingress."
  type        = string
  default     = ""
}

variable "k8s_dashboard_hostname" {
  description = "Specify the hostname for the k8s dashboard. "
  default     = ""
  type        = string
}

variable "ingress_class_name" {
  description = "resource name for nginx and internal nginx"
  type        = any
  default     = ""
}

variable "private_alb_enabled" {
  description = "Specify if require private load balancer"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "Subnet IDs required for load balancers"
  type        = list(string)
  default     = [""]
}

variable "addon_version" {
  description = "Helm Chart version for Kubernetes-dashboard"
  default     = "6.0.8"
  type        = string
}

variable "kubernetes_dashboard_config" {
  type = any
  default = {
    k8s_dashboard_hostname              = ""
    values_yaml                         = ""
    ingress_class_name                  = ""
    enable_service_monitor              = ""
    subnet_ids                          = []
    alb_acm_certificate_arn             = ""
    k8s_dashboard_ingress_load_balancer = "nlb"
    private_alb_enabled                 = false


  }
  description = "Specify the configuration settings for kubernetes-dashboard , including the hostname, and custom YAML values."
}
