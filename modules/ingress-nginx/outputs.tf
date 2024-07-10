output "argocd_gitops_config" {
  description = "Configuration used for managing the add-on with ArgoCD"
  value       = var.manage_via_gitops ? { enable = true } : null
}

output "release_metadata" {
  description = "Map of attributes of the Helm release metadata"
  value       = module.helm_addon[0].release_metadata
}

output "irsa_arn" {
  description = "IAM role ARN for the service account"
  value       = module.helm_addon[0].irsa_arn
}

output "irsa_name" {
  description = "IAM role name for the service account"
  value       = module.helm_addon[0].irsa_name
}

output "service_account" {
  description = "Name of Kubernetes service account"
  value       = module.helm_addon[0].service_account
}

output "nginx_ingress_controller_dns_hostname" {
  description = "DNS hostname of the NGINX Ingress Controller."
  value       = var.enable_public_nlb ? data.kubernetes_service.nginx-ingress[0].status[0].load_balancer[0].ingress[0].hostname : null
}

# output "internal_nginx_ingress_controller_dns_hostname" {
#   description = "DNS hostname of the NGINX Ingress Controller that can be used to access it from within the cluster."
#   value       = var.internal_ingress_nginx_enabled ? data.kubernetes_service.internal-nginx-ingress[0].status[0].load_balancer[0].ingress[0].hostname : null

# }
