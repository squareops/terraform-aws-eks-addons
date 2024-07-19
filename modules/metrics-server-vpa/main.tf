resource "helm_release" "metrics-server-vpa" {
  name      = "metricsservervpa"
  namespace = "kube-system"
  chart     = "${path.module}/metrics-server-vpa/"
  timeout   = 600
  values = [
    templatefile("${path.module}/config/values.yaml", {
      minCPU                      = var.metrics_server_vpa_config.minCPU,
      minMemory                   = var.metrics_server_vpa_config.minMemory,
      maxCPU                      = var.metrics_server_vpa_config.maxCPU,
      maxMemory                   = var.metrics_server_vpa_config.maxMemory,
      metricsServerDeploymentName = var.metrics_server_vpa_config.metricsServerDeploymentName
    })
  ]
}
