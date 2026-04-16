output "resource_id" {
  description = "Resource identifier (first audit config; null if none defined)"
  value       = length(google_project_iam_audit_config.this) > 0 ? values(google_project_iam_audit_config.this)[0].id : null
}

output "resource_arn" {
  description = "Resource ARN or equivalent (first audit config; null if none defined)"
  value       = length(google_project_iam_audit_config.this) > 0 ? values(google_project_iam_audit_config.this)[0].id : null
}

output "audit_config_ids" {
  description = "Map of service names to audit config IDs"
  value       = { for k, v in google_project_iam_audit_config.this : v.service => v.id }
}

output "resource_name" {
  description = "Resource name"
  value       = local.resource_name
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
