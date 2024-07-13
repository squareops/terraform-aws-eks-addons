output "id" {
  value       = var.enabled ? join("", aws_efs_file_system.default[*].id) : null
  description = "EFS ID"
}
