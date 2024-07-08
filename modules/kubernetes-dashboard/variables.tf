variable "kubernetes_dashboard_enabled" {
  description = "Determines whether k8s-dashboard is enabled or not"
  default     = false
  type        = bool
}

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