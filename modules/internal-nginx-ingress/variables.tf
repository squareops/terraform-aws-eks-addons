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

variable "internal_ingress_yaml_file" {
  description = "values file from outside the module"
  default =  ""
  type = any
}

variable "ip_family" {
  description = "ip family ipv4 and ipv6"
  type = string
  default = "ipv4"
}