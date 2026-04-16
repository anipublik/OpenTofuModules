output "resource_id" {
  description = "Resource identifier"
  value       = values(google_service_account.this)[0].id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = values(google_service_account.this)[0].id
}

output "service_account_emails" {
  description = "Map of service account IDs to emails"
  value       = { for k, v in google_service_account.this : v.account_id => v.email }
}

output "service_account_ids" {
  description = "Map of service account IDs to unique IDs"
  value       = { for k, v in google_service_account.this : v.account_id => v.unique_id }
}

output "resource_name" {
  description = "Resource name"
  value       = local.resource_name
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
