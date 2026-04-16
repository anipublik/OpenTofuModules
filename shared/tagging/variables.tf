variable "environment" {
  description = "Environment name (dev, staging, production)"
  type        = string
}

variable "team" {
  description = "Team name"
  type        = string
}

variable "cost_center" {
  description = "Cost center identifier"
  type        = string
}

variable "module_path" {
  description = "Module path (e.g., aws/compute/eks)"
  type        = string
}

variable "custom_tags" {
  description = "Custom tags to merge with required tags"
  type        = map(string)
  default     = {}
}
