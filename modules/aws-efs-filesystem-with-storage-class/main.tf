locals {
  # Returning null in the lookup function gives type errors and is not omitting the parameter.
  # This work around ensures null is returned.
  posix_users = {
    for k, v in var.access_points :
    k => lookup(var.access_points[k], "posix_user", {})
  }
  secondary_gids = {
    for k, v in var.access_points :
    k => lookup(local.posix_users[k], "secondary_gids", null)
  }
}

data "aws_vpc" "existing_vpc" {
  id = var.vpc_id
}

resource "aws_efs_file_system" "default" {
  #bridgecrew:skip=BC_AWS_GENERAL_48: BC complains about not having an AWS Backup plan. We ignore this because this can be done outside of this module.
  count                           = var.enabled ? 1 : 0
  availability_zone_name          = var.availability_zone_name
  encrypted                       = true
  kms_key_id                      = var.kms_key_arn != "" ? var.kms_key_arn : null
  performance_mode                = var.performance_mode
  provisioned_throughput_in_mibps = var.provisioned_throughput_in_mibps
  throughput_mode                 = var.throughput_mode

  dynamic "lifecycle_policy" {
    for_each = length(var.transition_to_ia) > 0 ? [1] : []
    content {
      transition_to_ia = try(var.transition_to_ia[0], null)
    }
  }

  dynamic "lifecycle_policy" {
    for_each = length(var.transition_to_primary_storage_class) > 0 ? [1] : []
    content {
      transition_to_primary_storage_class = try(var.transition_to_primary_storage_class[0], null)
    }
  }
}

resource "aws_efs_mount_target" "default" {
  count           = var.enabled && length(var.subnets) > 0 ? length(var.subnets) : 0
  file_system_id  = join("", aws_efs_file_system.default[*].id)
  ip_address      = var.mount_target_ip_address
  subnet_id       = var.subnets[count.index]
  security_groups = split(",", module.security_group_efs.security_group_id)

}

resource "aws_efs_access_point" "default" {
  for_each = var.enabled ? var.access_points : {}

  file_system_id = join("", aws_efs_file_system.default[*].id)

  dynamic "posix_user" {
    for_each = local.posix_users[each.key] != null ? ["true"] : []

    content {
      gid            = local.posix_users[each.key]["gid"]
      uid            = local.posix_users[each.key]["uid"]
      secondary_gids = local.secondary_gids[each.key] != null ? split(",", local.secondary_gids[each.key]) : null
    }
  }

  root_directory {
    path = "/${each.key}"

    dynamic "creation_info" {
      for_each = try(var.access_points[each.key]["creation_info"]["gid"], "") != "" ? ["true"] : []

      content {
        owner_gid   = var.access_points[each.key]["creation_info"]["gid"]
        owner_uid   = var.access_points[each.key]["creation_info"]["uid"]
        permissions = var.access_points[each.key]["creation_info"]["permissions"]
      }
    }
  }

  # tags = module.this.tags
}

resource "aws_efs_backup_policy" "policy" {
  count = var.enabled ? 1 : 0

  file_system_id = join("", aws_efs_file_system.default[*].id)

  backup_policy {
    status = var.efs_backup_policy_enabled ? "ENABLED" : "DISABLED"
  }
}

resource "aws_security_group_rule" "cidr_ingress" {
  description       = "From allowed CIDRs"
  type              = "ingress"
  from_port         = 2049
  to_port           = 2049
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.existing_vpc.cidr_block]
  security_group_id = module.security_group_efs.security_group_id
}

module "security_group_efs" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "~> 5"
  name        = format("%s-%s-%s", var.environment, var.name, "efs-sg")
  description = "Complete PostgreSQL example security group"
  vpc_id      = var.vpc_id
  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  tags = tomap(
    {
      "Name"        = format("%s-%s-%s", var.environment, var.name, "efs-sg")
      "Environment" = var.environment
    },
  )
}

resource "kubernetes_storage_class" "efs" {
  depends_on = [aws_efs_file_system.default]
  metadata {
    name = "efs-sc"
  }
  storage_provisioner = "efs.csi.aws.com"
  reclaim_policy      = "Retain"
  parameters = {
    provisioningMode : "efs-ap"
    fileSystemId : join("", aws_efs_file_system.default.*.id)
    directoryPerms : "777"
  }
}
