resource "helm_release" "karpenter_provisioner" {
  name    = var.karpenter_config.provisioner_name
  chart   = "${path.module}/karpenter_provisioner/"
  timeout = 600
  count = length(var.karpenter_config.karpenter_label)
  values = var.ipv6_enabled == true ? [
    templatefile("${path.module}/karpenter_provisioner/ipv6-values.yaml", {
      provisioner_name              = var.karpenter_config.provisioner_name,
      private_subnet_selector_key   = var.karpenter_config.private_subnet_selector_key,
      instance_capacity_type = var.karpenter_config.instance_capacity_type ,
       karpenter_label = element(var.karpenter_config.karpenter_label, count.index),
      private_subnet_selector_value = var.karpenter_config.private_subnet_selector_value,
      security_group_selector_key   = var.karpenter_config.security_group_selector_key,
      security_group_selector_value = var.karpenter_config.security_group_selector_value,
      instance_capacity_type        = "[${join(",", [for s in var.karpenter_config.instance_capacity_type : format("%s", s)])}]",
      excluded_instance_type        = "[${join(",", var.karpenter_config.excluded_instance_type)}]",
      ec2_instance_family           = "[${join(",", [for s in var.karpenter_config.ec2_instance_family : format("%s", s)])}]",
      ec2_instance_type             = "[${join(",", [for s in var.karpenter_config.ec2_instance_type : format("%s", s)])}]",
      instance_hypervisor           = "[${join(",", var.karpenter_config.instance_hypervisor)}]"
    }),
    var.karpenter_config.provisioner_values
    ] : [
    templatefile("${path.module}/karpenter_provisioner/ipv4-values.yaml", {
      provisioner_name              = var.karpenter_config.provisioner_name,
      private_subnet_selector_key   = var.karpenter_config.private_subnet_selector_key,
      private_subnet_selector_value = var.karpenter_config.private_subnet_selector_value,
      security_group_selector_key   = var.karpenter_config.security_group_selector_key,
      security_group_selector_value = var.karpenter_config.security_group_selector_value,
      instance_capacity_type = var.karpenter_config.instance_capacity_type ,
      karpenter_label = element(var.karpenter_config.karpenter_label, count.index),
      instance_capacity_type        = "[${join(",", [for s in var.karpenter_config.instance_capacity_type : format("%s", s)])}]",
      ec2_instance_family           = "[${join(",", [for s in var.karpenter_config.ec2_instance_family : format("%s", s)])}]",
      ec2_instance_type             = "[${join(",", [for s in var.karpenter_config.ec2_instance_type : format("%s", s)])}]",
      excluded_instance_type        = "[${join(",", var.karpenter_config.excluded_instance_type)}]"
    }),
    var.karpenter_config.provisioner_values
  ]
}
