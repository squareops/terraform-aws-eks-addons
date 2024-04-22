variable "name" {
  description = "Specify the name prefix of the EKS cluster resources."
  type        = string
  default     = ""
}

variable "cluster_id" {
  description = "Provide name of cluster to take backup."
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region for the EKS cluster"
  default     = "us-east-2"
  type        = string
}

variable "environment" {
  description = "Environment identifier for the EKS cluster"
  default     = ""
  type        = string
}

variable "velero_config" {
  description = "velero configurations"
  type        = any
  default = {
    slack_token                        = ""
    slack_channel_name                 = ""
    retention_period_in_days           = 45
    namespaces                         = ""
    schedule_cron_time                 = ""
    velero_backup_name                 = ""
    backup_bucket_name                 = ""
    s3_bucket_object_lock_mode_velero  = ""
    s3_bucket_object_lock_days_velero  = ""
    s3_bucket_object_lock_years_velero = ""
  }
}

variable "s3_bucket_lifecycle_rules_velero" {
  description = "A map of lifecycle rules for velero AWS S3 bucket."
  type = map(object({
    status                            = bool
    enable_glacier_transition         = optional(bool, false)
    enable_deeparchive_transition     = optional(bool, false)
    enable_standard_ia_transition     = optional(bool, false)
    enable_one_zone_ia                = optional(bool, false)
    enable_current_object_expiration  = optional(bool, false)
    enable_intelligent_tiering        = optional(bool, false)
    enable_glacier_ir                 = optional(bool, false)
    lifecycle_configuration_rule_name = optional(string, "lifecycle_configuration_rule_name")
    standard_transition_days          = optional(number, 30)
    glacier_transition_days           = optional(number, 60)
    deeparchive_transition_days       = optional(number, 150)
    one_zone_ia_days                  = optional(number, 40)
    intelligent_tiering_days          = optional(number, 50)
    glacier_ir_days                   = optional(number, 160)
    expiration_days                   = optional(number, 365)
  }))
  default = {
    default_rule = {
      status = false
    }
  }
}

variable "s3_bucket_enable_object_lock_velero" {
  description = "Whether to enable object lock or not on velero S3 bucket."
  type        = bool
  default     = true
}
