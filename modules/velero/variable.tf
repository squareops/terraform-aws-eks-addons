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
    slack_token              = ""
    slack_channel_name       = ""
    retention_period_in_days = 45
    namespaces               = ""
    schedule_cron_time       = ""
    velero_backup_name       = ""
    backup_bucket_name       = ""
  }
}

variable "velero_s3_bucket_enable_object_lock" {
  description = "Whether to enable object lock for loki-scalable S3 bucket."
  type        = bool
  default     = true
}

variable "velero_s3_bucket_object_lock_mode" {
  description = "Default Object Lock retention mode you want to apply to new objects placed in the loki-scalable S3 bucket. Valid values: COMPLIANCE, GOVERNANCE."
  type        = string
  default     = "GOVERNANCE"
}

variable "velero_s3_bucket_object_lock_days" {
  description = "Optional, Required if years is not specified. Number of days that you want to specify for the default retention period in loki-scalable S3 bucket."
  type        = number
  default     = 0
}

variable "velero_s3_bucket_object_lock_years" {
  description = "Optional, Required if days is not specified. Number of years that you want to specify for the default retention period in loki-scalable S3 bucket."
  type        = number
  default     = 0
}

variable "velero_s3_bucket_lifecycle_rules" {
  type = map(object({
    id                = string
    expiration_days   = number
    filter_prefix     = string
    status            = string
    transitions       = list(object({
      days          = number
      storage_class = string
    }))
  }))
  default = {
    rule1 = {
      id                = "rule1"
      expiration_days   = 30
      filter_prefix     = "prefix1"
      status            = "Enabled"
      transitions = [
        {
          days          = 60
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]
    }
    rule2 = {
      id                = "rule2"
      expiration_days   = 60
      filter_prefix     = "prefix2"
      status            = "Enabled"
      transitions = [
        {
          days          = 90
          storage_class = "STANDARD_IA"
        },
        {
          days          = 120
          storage_class = "GLACIER"
        }
      ]
    }
  }
}
