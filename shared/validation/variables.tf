variable "config" {
  description = "Parsed YAML configuration to validate"
  type        = any
}

variable "cloud_provider" {
  description = "Cloud provider (aws, azure, gcp, datadog)"
  type        = string
  default     = "aws"

  validation {
    condition     = contains(["aws", "azure", "gcp", "datadog"], var.cloud_provider)
    error_message = "cloud_provider must be one of: aws, azure, gcp, datadog"
  }
}

variable "resource_type" {
  description = "Type of resource being created"
  type        = string
  default     = "generic"
}
