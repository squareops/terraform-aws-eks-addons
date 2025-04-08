# Kubernetes Dashboard

## Introduction

[Kubernetes Dashboard](https://github.com/kubernetes/dashboard) is a general purpose, web-based UI for Kubernetes clusters. It allows users to manage applications running in the cluster and troubleshoot them, as well as manage the cluster itself.

This add-on bootstraps the Kubernetes Dashboard on the EKS cluster using a [helm chart](https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard) with the default configuration.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | ~> 2.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.10 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | ~> 2.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.10 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.kubernetes-dashboard](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_cluster_role.eks_read_only_role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.eks_read_only_role_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_cluster_role_binding_v1.admin-user](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding_v1) | resource |
| [kubernetes_ingress_v1.k8s-ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_namespace.k8s-dashboard](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |
| [kubernetes_secret_v1.admin-user](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_secret_v1.dashboard_read_only_sa_token](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret_v1) | resource |
| [kubernetes_service_account.dashboard_admin_sa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |
| [kubernetes_service_account.dashboard_read_only_sa](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_version"></a> [addon\_version](#input\_addon\_version) | Helm Chart version for Kubernetes-dashboard | `string` | `"6.0.8"` | no |
| <a name="input_alb_acm_certificate_arn"></a> [alb\_acm\_certificate\_arn](#input\_alb\_acm\_certificate\_arn) | ARN of the ACM certificate to be used for ALB Ingress. | `string` | `""` | no |
| <a name="input_ingress_class_name"></a> [ingress\_class\_name](#input\_ingress\_class\_name) | resource name for nginx and internal nginx | `any` | `""` | no |
| <a name="input_k8s_dashboard_hostname"></a> [k8s\_dashboard\_hostname](#input\_k8s\_dashboard\_hostname) | Specify the hostname for the k8s dashboard. | `string` | `""` | no |
| <a name="input_k8s_dashboard_ingress_load_balancer"></a> [k8s\_dashboard\_ingress\_load\_balancer](#input\_k8s\_dashboard\_ingress\_load\_balancer) | Controls whether to enable ALB Ingress or not. | `string` | `"nlb"` | no |
| <a name="input_kubernetes_dashboard_config"></a> [kubernetes\_dashboard\_config](#input\_kubernetes\_dashboard\_config) | Specify the configuration settings for kubernetes-dashboard , including the hostname, and custom YAML values. | `any` | <pre>{<br>  "alb_acm_certificate_arn": "",<br>  "enable_service_monitor": "",<br>  "ingress_class_name": "",<br>  "k8s_dashboard_hostname": "",<br>  "k8s_dashboard_ingress_load_balancer": "nlb",<br>  "private_alb_enabled": false,<br>  "subnet_ids": [],<br>  "values_yaml": ""<br>}</pre> | no |
| <a name="input_private_alb_enabled"></a> [private\_alb\_enabled](#input\_private\_alb\_enabled) | Specify if require private load balancer | `bool` | `false` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs required for load balancers | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_k8s-dashboard-admin-token"></a> [k8s-dashboard-admin-token](#output\_k8s-dashboard-admin-token) | n/a |
| <a name="output_k8s-dashboard-read-only-token"></a> [k8s-dashboard-read-only-token](#output\_k8s-dashboard-read-only-token) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
