
variable "cert_manager_letsencrypt_email" {
  description = "Email address for Let's Encrypt notifications"
  type        = string
}

variable "ingress_class_name" {
  description = "Enter the specific ingress class name"
  type        = string
}
