output "resource_id" {
  description = "Resource identifier"
  value       = google_kms_key_ring.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = google_kms_key_ring.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = google_kms_key_ring.this.name
}

output "key_ring_id" {
  description = "KMS key ring ID"
  value       = google_kms_key_ring.this.id
}

output "crypto_key_ids" {
  description = "Map of crypto key names to IDs"
  value       = { for k, v in google_kms_crypto_key.this : v.name => v.id }
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
