output "resource_id" {
  description = "Resource identifier"
  value       = google_sql_database_instance.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = google_sql_database_instance.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = google_sql_database_instance.this.name
}

output "instance_connection_name" {
  description = "Cloud SQL instance connection name"
  value       = google_sql_database_instance.this.connection_name
}

output "instance_ip_address" {
  description = "Cloud SQL instance IP address"
  value       = google_sql_database_instance.this.ip_address.0.ip_address
}

output "database_names" {
  description = "List of database names"
  value       = [for db in google_sql_database.this : db.name]
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
