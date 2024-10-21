# argocd

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.argocd_deploy](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_secret.argocd-secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd_config"></a> [argocd\_config](#input\_argocd\_config) | Specify the configuration settings for Argocd, including the hostname, redis\_ha\_enabled, autoscaling, notification settings, and custom YAML values. | `any` | <pre>{<br>  "argocd_notifications_enabled": false,<br>  "autoscaling_enabled": false,<br>  "hostname": "",<br>  "ingress_class_name": "",<br>  "redis_ha_enabled": false,<br>  "slack_notification_token": "",<br>  "values_yaml": ""<br>}</pre> | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Version of the Argocd chart that will be used to deploy Argocd application. | `string` | `"7.3.11"` | no |
| <a name="input_ingress_class_name"></a> [ingress\_class\_name](#input\_ingress\_class\_name) | Enter ingress class name which is created in EKS cluster | `string` | `"nginx"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Name of the Kubernetes namespace where the Argocd deployment will be deployed. | `string` | `"argocd"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd"></a> [argocd](#output\_argocd) | Argocd\_Info |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
