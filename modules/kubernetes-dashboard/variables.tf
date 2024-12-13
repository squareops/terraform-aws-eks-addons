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


variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs"
}

variable "private_subnet_ids" {
  description = "Private subnets of the VPC which can be used by EFS"
  default     = [""]
  type        = list(string)
}

