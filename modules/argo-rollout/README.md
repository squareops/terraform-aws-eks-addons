# argocd-workflow

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.argo_rollout](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_ingress_v1.argorollout-ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_secret.basic_auth_argo_rollout](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [random_password.argorollout_password](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argorollout_config"></a> [argorollout\_config](#input\_argorollout\_config) | Specify the configuration settings for Argocd-Rollout, including the hostname, and custom YAML values. | `any` | <pre>{<br>  "alb_acm_certificate_arn": "",<br>  "argorollout_ingress_load_balancer": "",<br>  "enable_dashboard": false,<br>  "hostname": "",<br>  "namespace": "",<br>  "private_alb_enabled": false,<br>  "subnet_ids": "",<br>  "values": {}<br>}</pre> | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Argo rollout chart version | `string` | `"2.38.0"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Name of the Kubernetes namespace where the Argocd deployment will be deployed. | `string` | `"argocd"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argorollout_credentials"></a> [argorollout\_credentials](#output\_argorollout\_credentials) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
