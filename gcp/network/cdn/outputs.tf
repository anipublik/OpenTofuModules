output "resource_id" {
  description = "Resource identifier"
  value       = google_compute_url_map.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = google_compute_url_map.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = google_compute_url_map.this.name
}

output "url_map_id" {
  description = "URL map ID"
  value       = google_compute_url_map.this.id
}

output "ip_address" {
  description = "CDN IP address"
  value       = google_compute_global_address.this.address
}

output "backend_bucket_ids" {
  description = "Map of backend bucket names to IDs"
  value       = { for k, v in google_compute_backend_bucket.this : v.name => v.id }
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
