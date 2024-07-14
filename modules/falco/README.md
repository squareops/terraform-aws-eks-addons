# falco

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 1.0.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 1.11.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 1.0.0 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 1.11.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.falco](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [kubernetes_namespace.falco](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/namespace) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_falco_enabled"></a> [falco\_enabled](#input\_falco\_enabled) | Enable or disable Falco deployment | `bool` | `true` | no |
| <a name="input_slack_webhook"></a> [slack\_webhook](#input\_slack\_webhook) | Slack webhook URL for Falco alerts | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_falco_namespace"></a> [falco\_namespace](#output\_falco\_namespace) | The namespace where Falco is deployed |
| <a name="output_falco_release"></a> [falco\_release](#output\_falco\_release) | The Helm release name for Falco |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
