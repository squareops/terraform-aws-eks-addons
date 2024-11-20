# argocd-workflow

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
| [helm_release.argo_workflow](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_cluster_role.argo_workflow_role](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role) | resource |
| [kubernetes_cluster_role_binding.argo_workflow_binding](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/cluster_role_binding) | resource |
| [kubernetes_ingress_v1.argoworkflow-ingress](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/ingress_v1) | resource |
| [kubernetes_secret.argo_workflow_token_secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/secret) | resource |
| [kubernetes_service_account_v1.argoworkflows-service-account](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account_v1) | resource |
| [kubernetes_secret.argo-workflow-secret](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/data-sources/secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argoworkflow_config"></a> [argoworkflow\_config](#input\_argoworkflow\_config) | Specify the configuration settings for Argocd-Workflow, including the hostname, and custom YAML values. | `any` | <pre>{<br/>  "alb_acm_certificate_arn": "",<br/>  "argoworkflow_ingress_load_balancer": "nlb",<br/>  "autoscaling_enabled": "true",<br/>  "hostname": "",<br/>  "ingress_class_name": "",<br/>  "namespace": "",<br/>  "private_alb_enabled": false,<br/>  "values": {}<br/>}</pre> | no |
| <a name="input_argoworkflow_host"></a> [argoworkflow\_host](#input\_argoworkflow\_host) | Define the host for argo workflow server | `string` | `""` | no |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Argo workflow chart version | `string` | `"0.29.2"` | no |
| <a name="input_ingress_class_name"></a> [ingress\_class\_name](#input\_ingress\_class\_name) | Enter ingress class name which is created in EKS cluster | `string` | `"nginx"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Name of the Kubernetes namespace where the Argocd deployment will be deployed. | `string` | `"argocd"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argo_workflow_token"></a> [argo\_workflow\_token](#output\_argo\_workflow\_token) | n/a |
| <a name="output_argoworkflow_host"></a> [argoworkflow\_host](#output\_argoworkflow\_host) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
