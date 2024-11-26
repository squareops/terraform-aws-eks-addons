# karpenter-provisioner

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.26 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | >= 2.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.karpenter_provisioner](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ipv6_enabled"></a> [ipv6\_enabled](#input\_ipv6\_enabled) | Whether to enable IPv6 or not | `bool` | `false` | no |
| <a name="input_karpenter_config"></a> [karpenter\_config](#input\_karpenter\_config) | Configuration values for Karpenter provisioning | <pre>object({<br>    provisioner_name              = string<br>    karpenter_label               = list(string)<br>    provisioner_values            = string<br>    private_subnet_selector_key   = optional(string, "Name")<br>    private_subnet_selector_value = string<br>    security_group_selector_key   = optional(string, "aws:eks:cluster-name")<br>    security_group_selector_value = string<br>    instance_capacity_type        = optional(list(string), ["spot"])<br>    excluded_instance_type        = optional(list(string), ["nano", "micro", "small"])<br>    ec2_instance_family           = optional(list(string), ["t3"])<br>    ec2_instance_type             = optional(list(string), ["t3.medium"])<br>    instance_hypervisor           = optional(list(string), ["nitro"])<br>    kms_key_arn                   = optional(string, "")<br>    ec2_node_name                 = optional(string, "")<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
