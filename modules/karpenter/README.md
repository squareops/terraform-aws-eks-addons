# Karpenter

Karpenter is an open-source node provisioning project built for Kubernetes. Karpenter automatically launches just the right compute resources to handle your cluster's applications. It is designed to let you take full advantage of the cloud with fast and simple compute provisioning for Kubernetes clusters.

For more details checkout [Karpenter](https://karpenter.sh/docs/getting-started/) docs


| Module Release           | Karpenter v0.32.x | Karpenter v1.0.0  |
|-------------------|------------------|------------------|
| 3.0.0     | &#x2714;        | &#x274C;         |
| 3.1.1     | &#x274C;         | &#x2714;        |

## Notes
1. The module release v3.1.1 support karpenter version 1.0.0  which have nodepool and ec2nodeclass support. For Karpenter version <=0.32.x refer the previous release.
2. If you are already using Karpenter below version 0.32.x, kindly refer to the [Karpenter v1 Migration Guide](https://karpenter.sh/docs/getting-started/migration/v1/) for important upgrade instructions.  
For more details, check out the [Karpenter documentation](https://karpenter.sh/docs/).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 3.72 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0.0, < 4.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.72 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.0.0, < 4.0.0 |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_helm_addon"></a> [helm\_addon](#module\_helm\_addon) | ../helm-addon | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.karpenter_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.karpenter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.karpenter-spot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [helm_release.karpenter_crd](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [null_resource.patch_karpenter_crds](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_iam_policy_document.karpenter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.karpenter-spot-service-linked-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.default_kms_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_addon_context"></a> [addon\_context](#input\_addon\_context) | Input configuration for the addon | <pre>object({<br>    aws_caller_identity_account_id = string<br>    aws_caller_identity_arn        = string<br>    aws_eks_cluster_endpoint       = string<br>    aws_partition_id               = string<br>    aws_region_name                = string<br>    eks_cluster_id                 = string<br>    eks_oidc_issuer_url            = string<br>    eks_oidc_provider_arn          = string<br>    tags                           = map(string)<br>    irsa_iam_role_path             = string<br>    irsa_iam_permissions_boundary  = string<br>  })</pre> | n/a | yes |
| <a name="input_chart_version"></a> [chart\_version](#input\_chart\_version) | Helm cart version for karpenter CRDs | `string` | `"1.3.1"` | no |
| <a name="input_eks_cluster_name"></a> [eks\_cluster\_name](#input\_eks\_cluster\_name) | Fetch Cluster ID of the cluster | `string` | `""` | no |
| <a name="input_enable_service_monitor"></a> [enable\_service\_monitor](#input\_enable\_service\_monitor) | Specifies whether a ServiceMonitor should be created. | `bool` | `false` | no |
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Helm provider config for the Karpenter | `any` | `{}` | no |
| <a name="input_irsa_policies"></a> [irsa\_policies](#input\_irsa\_policies) | Additional IAM policies for a IAM role for service accounts | `list(string)` | `[]` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | Cluster kms key for encryption | `string` | `""` | no |
| <a name="input_manage_via_gitops"></a> [manage\_via\_gitops](#input\_manage\_via\_gitops) | Determines if the add-on should be managed via GitOps. | `bool` | `false` | no |
| <a name="input_node_iam_instance_profile"></a> [node\_iam\_instance\_profile](#input\_node\_iam\_instance\_profile) | Karpenter Node IAM Instance profile id | `string` | `""` | no |
| <a name="input_worker_iam_role_name"></a> [worker\_iam\_role\_name](#input\_worker\_iam\_role\_name) | Specify the IAM role for the nodes that will be provisioned through karpenter | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_argocd_gitops_config"></a> [argocd\_gitops\_config](#output\_argocd\_gitops\_config) | Configuration used for managing the add-on with ArgoCD |
| <a name="output_irsa_arn"></a> [irsa\_arn](#output\_irsa\_arn) | IAM role ARN for the service account |
| <a name="output_irsa_name"></a> [irsa\_name](#output\_irsa\_name) | IAM role name for the service account |
| <a name="output_release_metadata"></a> [release\_metadata](#output\_release\_metadata) | Map of attributes of the Helm release metadata |
| <a name="output_service_account"></a> [service\_account](#output\_service\_account) | Name of Kubernetes service account |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
