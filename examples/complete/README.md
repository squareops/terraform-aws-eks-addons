# complete

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.43.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.7.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.0.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.43.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks-addons"></a> [eks-addons](#module\_eks-addons) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eks_cluster.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster) | data source |
| [aws_eks_cluster_auth.cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_defectdojo"></a> [defectdojo](#output\_defectdojo) | DefectDojo endpoint and credentials |
| <a name="output_ebs_encryption_enable"></a> [ebs\_encryption\_enable](#output\_ebs\_encryption\_enable) | Whether Amazon Elastic Block Store (EBS) encryption is enabled or not. |
| <a name="output_efs_id"></a> [efs\_id](#output\_efs\_id) | ID of the Amazon Elastic File System (EFS) that has been created for the EKS cluster. |
| <a name="output_environment"></a> [environment](#output\_environment) | Environment Name for the EKS cluster |
| <a name="output_istio_ingressgateway_dns_hostname"></a> [istio\_ingressgateway\_dns\_hostname](#output\_istio\_ingressgateway\_dns\_hostname) | DNS hostname of the Istio Ingress Gateway |
| <a name="output_k8s-dashboard-admin-token"></a> [k8s-dashboard-admin-token](#output\_k8s-dashboard-admin-token) | n/a |
| <a name="output_k8s-dashboard-read-only-token"></a> [k8s-dashboard-read-only-token](#output\_k8s-dashboard-read-only-token) | n/a |
| <a name="output_kubeclarity"></a> [kubeclarity](#output\_kubeclarity) | Kubeclarity endpoint and credentials |
| <a name="output_kubecost"></a> [kubecost](#output\_kubecost) | Kubecost endpoint and credentials |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
