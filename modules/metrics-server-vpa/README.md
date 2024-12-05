# metrics-server-vpa

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.metrics-server-vpa](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_metrics_server_vpa_config"></a> [metrics\_server\_vpa\_config](#input\_metrics\_server\_vpa\_config) | Configuration to provide settings of vpa over metrics server | `any` | <pre>{<br/>  "maxCPU": "100m",<br/>  "maxMemory": "500Mi",<br/>  "metricsServerDeploymentName": "metrics-server",<br/>  "minCPU": "25m",<br/>  "minMemory": "150Mi"<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
