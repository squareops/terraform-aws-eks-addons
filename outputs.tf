output "nginx_ingress_controller_dns_hostname" {
  description = "DNS hostname of the NGINX Ingress Controller."
  value       = var.ingress_nginx_enabled ? data.kubernetes_service.nginx-ingress[0].status[0].load_balancer[0].ingress[0].hostname : null
}

output "ebs_encryption_enable" {
  description = "Whether Amazon Elastic Block Store (EBS) encryption is enabled or not."
  value       = "Encrypted by default"
}

output "efs_id" {
  description = "ID of the Amazon Elastic File System (EFS) that has been created for the EKS cluster."
  value       = var.efs_storage_class_enabled ? module.efs.*.id : null
}

output "internal_nginx_ingress_controller_dns_hostname" {
  description = "DNS hostname of the NGINX Ingress Controller that can be used to access it from within the cluster."
  value       = var.internal_ingress_nginx_enabled ? data.kubernetes_service.internal-nginx-ingress[0].status[0].load_balancer[0].ingress[0].hostname : null

}

output "kubeclarity" {
  description = "Kubeclarity endpoint and credentials"
  value = var.kubeclarity_enabled ? {
    username = "admin",
    password = nonsensitive(random_password.kube_clarity[0].result),
    url      = var.kubeclarity_hostname
  } : null
}

output "kubecost" {
  description = "Kubecost endpoint and credentials"
  value = var.kubecost_enabled ? {
    username = "admin",
    password = nonsensitive(random_password.kubecost[0].result),
    url      = var.kubecost_hostname
  } : null
}

output "istio_ingressgateway_dns_hostname" {
  description = "DNS hostname of the Istio Ingress Gateway."
  value       = var.istio_enabled ? data.kubernetes_service.istio-ingress[0].status[0].load_balancer[0].ingress[0].hostname : null
}

output "defectdojo" {
  description = "DefectDojo endpoint and credentials"
  value = var.defectdojo_enabled ? {
    username = "admin",
    password = nonsensitive(data.kubernetes_secret.defectdojo[0].data["DD_ADMIN_PASSWORD"]),
    url      = var.defectdojo_hostname
  } : null
}

output "k8s-dashboard-admin-token" {
  description = "The token for the Kubernetes dashboard admin user. This token is available only if the Kubernetes dashboard is enabled."
  value       = var.kubernetes_dashboard_enabled ? nonsensitive(kubernetes_secret_v1.admin-user[0].data.token) : null
}

output "k8s-dashboard-read-only-token" {
  description = "The token for the read-only user of the Kubernetes dashboard. This token is provided only if the Kubernetes dashboard is enabled."
  value       = var.kubernetes_dashboard_enabled ? nonsensitive(kubernetes_secret_v1.dashboard_read_only_sa_token[0].data.token) : null
}
