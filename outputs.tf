output "environment" {
  description = "Environment Name for the EKS cluster"
  value       = var.environment
}

output "nginx_ingress_controller_dns_hostname" {
  description = "DNS hostname of the NGINX Ingress Controller."
  value       = var.enable_public_nlb ? module.ingress-nginx.nginx_ingress_controller_dns_hostname : null
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


