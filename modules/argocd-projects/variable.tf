variable "namespace" {
  description = "Namespace on which argocd-project will get deployed"
  default     = ""
  type        = string
}

variable "name" {
  description = "Name of argo-project"
  default     = ""
  type        = string
}
