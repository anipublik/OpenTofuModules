output "resource_id" {
  description = "Resource identifier"
  value       = length(google_access_context_manager_access_policy.this) > 0 ? google_access_context_manager_access_policy.this[0].id : null
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = length(google_access_context_manager_access_policy.this) > 0 ? google_access_context_manager_access_policy.this[0].name : null
}

output "access_policy_name" {
  description = "Access policy name"
  value       = length(google_access_context_manager_access_policy.this) > 0 ? google_access_context_manager_access_policy.this[0].name : null
}

output "access_level_names" {
  description = "Map of access level titles to names"
  value       = { for k, v in google_access_context_manager_access_level.this : v.title => v.name }
}

output "service_perimeter_names" {
  description = "Map of service perimeter titles to names"
  value       = { for k, v in google_access_context_manager_service_perimeter.this : v.title => v.name }
}

output "resource_name" {
  description = "Resource name"
  value       = local.resource_name
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
