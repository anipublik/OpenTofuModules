output "tags" {
  description = "Merged tags with required and custom tags"
  value       = local.tags
}

output "labels" {
  description = "Provider-safe labels derived from tags"
  value       = local.labels
}

output "required_tags" {
  description = "Required tags only"
  value       = local.required_tags
}
