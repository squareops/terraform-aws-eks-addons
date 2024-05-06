output "nginx_ingress_controller_dns_hostname" {
  description = "DNS hostname of the NGINX Ingress Controller."
  value       = module.eks-addons.nginx_ingress_controller_dns_hostname
}

output "ebs_encryption_enable" {
  description = "Whether Amazon Elastic Block Store (EBS) encryption is enabled or not."
  value       = "Encrypted by default"
}

output "efs_id" {
  value       = module.eks-addons.efs_id
  description = "ID of the Amazon Elastic File System (EFS) that has been created for the EKS cluster."
}

output "defectdojo" {
  description = "DefectDojo endpoint and credentials"
  value       = module.eks-addons.defectdojo
}

output "internal_nginx_ingress_controller_dns_hostname" {
  description = "DNS hostname of the NGINX Ingress Controller that can be used to access it from within the cluster."
  value       = module.eks-addons.internal_nginx_ingress_controller_dns_hostname
}

output "kubeclarity" {
  value       = module.eks-addons.kubeclarity
  description = "Kubeclarity endpoint and credentials"
}

output "kubecost" {
  value       = module.eks-addons.kubecost
  description = "Kubecost endpoint and credentials"
}

output "istio_ingressgateway_dns_hostname" {
  value       = module.eks-addons.istio_ingressgateway_dns_hostname
  description = "DNS hostname of the Istio Ingress Gateway"
}

output "k8s-dashboard-admin-token" {
  description = "k8s-dashboard admin token"
  value       = module.eks-addons.k8s-dashboard-admin-token
}

output "k8s-dashboard-read-only-token" {
  description = "k8s-dashboard read only  token"
  value       = module.eks-addons.k8s-dashboard-read-only-token
}
