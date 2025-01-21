variable "helm-config" {
  description = "vpa config from user end"
  type        = any
  default     = {}
}

variable "chart_version" {
  description = "chart version for VPA"
  type        = string
  default     = "9.9.0"
}
