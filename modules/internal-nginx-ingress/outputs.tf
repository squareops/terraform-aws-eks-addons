output "internal_nginx_ingress_controller_dns_hostname" {
  description = "DNS hostname of the NGINX Ingress Controller that can be used to access it from within the cluster."
  value       = var.internal_ingress_nginx_enabled ? data.kubernetes_service.internal-nginx-ingress[0].status[0].load_balancer[0].ingress[0].hostname : null

}
# output "internal_nginx_ingress_controller_dns_hostname" {
#   description = "DNS hostname of the NGINX Ingress Controller that can be used to access it from within the cluster."
#   value       = module.eks-addons.internal_nginx_ingress_controller_dns_hostname
# }