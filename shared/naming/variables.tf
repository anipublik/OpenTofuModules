variable "environment" {
  description = "Environment name"
  type        = string
}

variable "team" {
  description = "Team name"
  type        = string
}

variable "resource_type" {
  description = "Resource type (e.g., eks, s3, vpc)"
  type        = string
}

variable "name" {
  description = "Resource name"
  type        = string
}

variable "cloud_provider" {
  description = "Cloud provider (aws, azure, gcp, datadog)"
  type        = string
  validation {
    condition     = contains(["aws", "azure", "gcp", "datadog"], var.cloud_provider)
    error_message = "cloud_provider must be one of: aws, azure, gcp, datadog"
  }
}
