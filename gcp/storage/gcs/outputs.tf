output "resource_id" {
  description = "Resource identifier"
  value       = google_storage_bucket.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = google_storage_bucket.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = google_storage_bucket.this.name
}

output "bucket_name" {
  description = "GCS bucket name"
  value       = google_storage_bucket.this.name
}

output "bucket_url" {
  description = "GCS bucket URL"
  value       = google_storage_bucket.this.url
}

output "bucket_self_link" {
  description = "GCS bucket self link"
  value       = google_storage_bucket.this.self_link
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
