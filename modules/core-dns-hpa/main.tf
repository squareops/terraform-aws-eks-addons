resource "helm_release" "coredns-hpa" {
  name      = var.release_name
  namespace = var.namespace
  chart     = var.chart_path
  timeout   = var.timeout
  values    = [templatefile("${path.module}/config/values.yaml", {
    minReplicas                       = var.min_replicas,
    maxReplicas                       = var.max_replicas,
    corednsdeploymentname             = var.corednsdeploymentname,
    targetCPUUtilizationPercentage    = var.target_cpu_utilization_percentage,
    targetMemoryUtilizationPercentage = var.target_memory_utilization_percentage
  })]
}
