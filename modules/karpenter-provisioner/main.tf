locals {
  kms_key_id = var.karpenter_config.kms_key_arn != "" ? regex("key/([a-f0-9\\-]+)", var.karpenter_config.kms_key_arn)[0] : ""
}

resource "helm_release" "karpenter_provisioner" {
  count   = length(var.karpenter_config.karpenter_label)
  name    = "${var.karpenter_config.provisioner_name}-${count.index}"
  chart   = "${path.module}/config/"
  timeout = 600
  values = var.ipv6_enabled == true ? [
    templatefile("${path.module}/config/ipv6-values.yaml", {
      provisioner_name              = "${var.karpenter_config.provisioner_name}-${count.index}",
      private_subnet_selector_key   = var.karpenter_config.private_subnet_selector_key,
      private_subnet_selector_value = var.karpenter_config.private_subnet_selector_value,
      security_group_selector_key   = var.karpenter_config.security_group_selector_key,
      security_group_selector_value = var.karpenter_config.security_group_selector_value,
      karpenter_label               = element(var.karpenter_config.karpenter_label, count.index),
      instance_capacity_type        = "[${join(",", [for s in var.karpenter_config.instance_capacity_type : format("%s", s)])}]",
      excluded_instance_type        = "[${join(",", var.karpenter_config.excluded_instance_type)}]",
      ec2_instance_family           = "[${join(",", [for s in var.karpenter_config.ec2_instance_family : format("%s", s)])}]",
      ec2_instance_type             = "[${join(",", [for s in var.karpenter_config.ec2_instance_type : format("%s", s)])}]",
      instance_hypervisor           = "[${join(",", var.karpenter_config.instance_hypervisor)}]"
      kms_key_id                    = local.kms_key_id
    }),
    var.karpenter_config.provisioner_values
    ] : [
    templatefile("${path.module}/config/ipv4-values.yaml", {
      provisioner_name              = "${var.karpenter_config.provisioner_name}-${count.index}",
      private_subnet_selector_key   = var.karpenter_config.private_subnet_selector_key,
      private_subnet_selector_value = var.karpenter_config.private_subnet_selector_value,
      security_group_selector_key   = var.karpenter_config.security_group_selector_key,
      security_group_selector_value = var.karpenter_config.security_group_selector_value,
      karpenter_label               = element(var.karpenter_config.karpenter_label, count.index),
      instance_capacity_type        = "[${join(",", [for s in var.karpenter_config.instance_capacity_type : format("%s", s)])}]",
      excluded_instance_type        = "[${join(",", var.karpenter_config.excluded_instance_type)}]",
      ec2_instance_family           = "[${join(",", [for s in var.karpenter_config.ec2_instance_family : format("%s", s)])}]",
      ec2_instance_type             = "[${join(",", [for s in var.karpenter_config.ec2_instance_type : format("%s", s)])}]",
      kms_key_id                    = local.kms_key_id
    }),
    var.karpenter_config.provisioner_values
  ]
}
