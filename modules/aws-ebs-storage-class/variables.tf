variable "kms_key_id" {
  type        = string
  default     = ""
  description = "KMS key to Encrypt storage class."
}

variable "single_az_ebs_gp3_storage_class_name" {
  type        = string
  default     = ""
  description = "Name for the single az storage class"
}

variable "single_az_ebs_gp3_storage_class" {
  type        = bool
  default     = false
  description = "Enable Single az storage class."
}

variable "availability_zone" {
  type        = any
  description = "List of Azs"
}

variable "tags_all" {
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
  type        = map(string)
  default     = {}
}
