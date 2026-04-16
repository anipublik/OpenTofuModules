output "resource_id" {
  description = "Resource identifier"
  value       = google_spanner_instance.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = google_spanner_instance.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = google_spanner_instance.this.name
}

output "instance_id" {
  description = "Spanner instance ID"
  value       = google_spanner_instance.this.id
}

output "instance_name" {
  description = "Spanner instance name"
  value       = google_spanner_instance.this.name
}

output "database_ids" {
  description = "Map of database names to IDs"
  value       = { for k, v in google_spanner_database.this : v.name => v.id }
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
