output "resource_id" {
  description = "Resource identifier"
  value       = google_cloud_run_v2_service.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = google_cloud_run_v2_service.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = google_cloud_run_v2_service.this.name
}

output "service_id" {
  description = "Cloud Run service ID"
  value       = google_cloud_run_v2_service.this.id
}

output "service_uri" {
  description = "Cloud Run service URI"
  value       = google_cloud_run_v2_service.this.uri
}

output "service_url" {
  description = "Cloud Run service URL"
  value       = google_cloud_run_v2_service.this.uri
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
