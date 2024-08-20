variable "metrics_server_vpa_config" {
  description = "Configuration to provide settings of vpa over metrics server"
  default = {

    minCPU                      = "25m"
    maxCPU                      = "100m"
    minMemory                   = "150Mi"
    maxMemory                   = "500Mi"
    metricsServerDeploymentName = "metrics-server"
  }
  type = any
}
