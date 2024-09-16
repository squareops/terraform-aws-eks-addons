variable "karpenter_config" {
  description = "Configuration values for Karpenter provisioning"
  type = object({
    provisioner_name              = string
    karpenter_label               = list(string)
    provisioner_values            = string
    private_subnet_selector_key   = optional(string, "Name")
    private_subnet_selector_value = string
    security_group_selector_key   = optional(string, "aws:eks:cluster-name")
    security_group_selector_value = string
    instance_capacity_type        = optional(list(string), ["spot"])
    excluded_instance_type        = optional(list(string), ["nano", "micro", "small"])
    ec2_instance_family           = optional(list(string), ["t3"])
    ec2_instance_type             = optional(list(string), ["t3.medium"])
    instance_hypervisor           = optional(list(string), ["nitro"])
    kms_key_arn                   = optional(string, "")
    ec2_node_name                 = optional(string, "")
  })
}

variable "ipv6_enabled" {
  description = "Whether to enable IPv6 or not"
  type        = bool
  default     = false
}

