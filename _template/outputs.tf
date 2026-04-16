output "resource_id" {
  description = "Resource identifier"
  value       = "REPLACE_WITH_ACTUAL_RESOURCE_ID"
}

output "resource_arn" {
  description = "Resource ARN (or equivalent identifier)"
  value       = "REPLACE_WITH_ACTUAL_RESOURCE_ARN"
}

output "resource_name" {
  description = "Resource name"
  value       = local.naming
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}

# Add additional outputs as needed
