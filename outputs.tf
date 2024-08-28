output "environment" {
  description = "Environment Name for the EKS cluster"
  value       = var.environment
}

output "nginx_ingress_controller_dns_hostname" {
  description = "DNS hostname of the NGINX Ingress Controller."
  value       = var.ingress_nginx_enabled ? var.private_nlb_enabled ? null : data.kubernetes_service.ingress-nginx[0].status[0].load_balancer[0].ingress[0].hostname : null
}

output "internal_nginx_ingress_controller_dns_hostname" {
  description = "DNS hostname of the NGINX Ingress Controller."
  value       = var.private_nlb_enabled ? data.kubernetes_service.ingress-nginx[0].status[0].load_balancer[0].ingress[0].hostname : null
}

output "ebs_encryption_enable" {
  description = "Whether Amazon Elastic Block Store (EBS) encryption is enabled or not."
  value       = "Encrypted by default"
}

output "efs_id" {
  value       = var.efs_storage_class_enabled ? module.aws-efs-filesystem-with-storage-class.*.id : null
  description = "ID of the Amazon Elastic File System (EFS) that has been created for the EKS cluster."
}

output "kubeclarity" {
  description = "Kubeclarity endpoint and credentials"
  value = var.kubeclarity_enabled ? {
    username = "admin",
    password = nonsensitive(random_password.kube-clarity[0].result),
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

output "defectdojo" {
  description = "DefectDojo endpoint and credentials"
  value = var.defectdojo_enabled ? {
    username = "admin",
    password = nonsensitive(data.kubernetes_secret.defectdojo[0].data["DD_ADMIN_PASSWORD"]),
    url      = var.defectdojo_hostname
  } : null
}

output "k8s_dashboard_admin_token" {
  description = "Kubernetes-Dashboard Admin Token"
  value       = var.kubernetes_dashboard_enabled ? module.kubernetes-dashboard[0].k8s-dashboard-admin-token : ""
}

output "k8s_dashboard_read_only_token" {
  description = "Kubernetes-Dashboard Read Only Token"
  value       = var.kubernetes_dashboard_enabled ? module.kubernetes-dashboard[0].k8s-dashboard-read-only-token : ""
}
