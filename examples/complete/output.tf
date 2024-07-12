# output "environment" {
#   description = "Environment Name for the EKS cluster"
#   value       = local.environment
# }

# output "nginx_ingress_controller_dns_hostname" {
#   description = "DNS hostname of the NGINX Ingress Controller."
#   value       = module.eks-addons.nginx_ingress_controller_dns_hostname
# }

# output "ebs_encryption_enable" {
#   description = "Whether Amazon Elastic Block Store (EBS) encryption is enabled or not."
#   value       = "Encrypted by default"
# }

# output "efs_id" {
#   value       = module.eks-addons.efs_id
#   description = "ID of the Amazon Elastic File System (EFS) that has been created for the EKS cluster."
# }

# output "defectdojo" {
#   description = "DefectDojo endpoint and credentials"
#   value       = module.eks-addons.defectdojo
# }

# output "kubeclarity" {
#   value       = module.eks-addons.kubeclarity
#   description = "Kubeclarity endpoint and credentials"
# }

# output "kubecost" {
#   value       = module.eks-addons.kubecost
#   description = "Kubecost endpoint and credentials"
# }

# output "istio_ingressgateway_dns_hostname" {
#   value       = module.eks-addons.istio_ingressgateway_dns_hostname
#   description = "DNS hostname of the Istio Ingress Gateway"
# }
output "enable_nginx_nlb_private_value" {
  value = module.eks-addons.enable_nginx_nlb_private_value
}

output "ingress_class_resource_name" {
  value = module.eks-addons.ingress_class_resource_name
}


output "enable_nginx_nlb_private_value_2" {
  value = module.eks-addons2.enable_nginx_nlb_private_value
}

output "ingress_class_resource_name_2" {
  value = module.eks-addons2.ingress_class_resource_name
}
