variable "release_name" {
  description = "Name of the Helm release"
  type        = string
}

variable "namespace" {
  description = "Namespace where Helm release will be installed"
  type        = string
}

variable "chart_path" {
  description = "Path to the Helm chart"
  type        = string
}

variable "timeout" {
  description = "Timeout in seconds for installing the Helm release"
  type        = number
}

variable "min_replicas" {
  description = "Minimum number of replicas"
  type        = number
}

variable "max_replicas" {
  description = "Maximum number of replicas"
  type        = number
}

variable "corednsdeploymentname" {
  description = "Name of the CoreDNS deployment"
  type        = string
}

variable "target_cpu_utilization_percentage" {
  description = "Target CPU utilization percentage for HPA"
  type        = number
}

variable "target_memory_utilization_percentage" {
  description = "Target memory utilization percentage for HPA"
  type        = string
}
