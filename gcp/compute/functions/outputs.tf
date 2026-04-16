output "resource_id" {
  description = "Resource identifier"
  value       = google_cloudfunctions2_function.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = google_cloudfunctions2_function.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = google_cloudfunctions2_function.this.name
}

output "function_uri" {
  description = "Cloud Function URI"
  value       = google_cloudfunctions2_function.this.service_config[0].uri
}

output "function_url" {
  description = "Cloud Function URL"
  value       = google_cloudfunctions2_function.this.url
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
