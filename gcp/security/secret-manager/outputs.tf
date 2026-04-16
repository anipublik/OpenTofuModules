output "resource_id" {
  description = "Resource identifier"
  value       = values(google_secret_manager_secret.this)[0].id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = values(google_secret_manager_secret.this)[0].id
}

output "secret_ids" {
  description = "Map of secret names to IDs"
  value       = { for k, v in google_secret_manager_secret.this : v.secret_id => v.id }
}

output "secret_names" {
  description = "Map of secret names to full resource names"
  value       = { for k, v in google_secret_manager_secret.this : v.secret_id => v.name }
}

output "resource_name" {
  description = "Resource name"
  value       = local.resource_name
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
