output "resource_id" {
  description = "Resource identifier (first sink; null if none defined)"
  value       = length(google_logging_project_sink.this) > 0 ? values(google_logging_project_sink.this)[0].id : null
}

output "resource_arn" {
  description = "Resource ARN or equivalent (first sink; null if none defined)"
  value       = length(google_logging_project_sink.this) > 0 ? values(google_logging_project_sink.this)[0].id : null
}

output "sink_ids" {
  description = "Map of sink names to IDs"
  value       = { for k, v in google_logging_project_sink.this : v.name => v.id }
}

output "writer_identities" {
  description = "Map of sink names to writer identities"
  value       = { for k, v in google_logging_project_sink.this : v.name => v.writer_identity }
}

output "resource_name" {
  description = "Resource name"
  value       = local.resource_name
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
