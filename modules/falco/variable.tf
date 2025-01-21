variable "falco_enabled" {
  description = "Enable or disable Falco deployment"
  type        = bool
  default     = true
}

variable "slack_webhook" {
  description = "Slack webhook URL for Falco alerts"
  type        = string
  default     = ""
}

variable "version" {
  description = "Helm Chart version of Falco"
  type        = string
  default     = ""
}
