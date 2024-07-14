# core-dns-hpa

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 1.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.coredns-hpa](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_helm_config"></a> [helm\_config](#input\_helm\_config) | Path to the values.yaml file that overwrites the default values | `any` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_helm_release_status"></a> [helm\_release\_status](#output\_helm\_release\_status) | Status of the Helm release |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
