output "resource_id" {
  description = "Resource identifier"
  value       = google_redis_instance.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = google_redis_instance.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = google_redis_instance.this.name
}

output "redis_host" {
  description = "Redis instance host"
  value       = google_redis_instance.this.host
}

output "redis_port" {
  description = "Redis instance port"
  value       = google_redis_instance.this.port
}

output "redis_current_location_id" {
  description = "Redis instance current location"
  value       = google_redis_instance.this.current_location_id
}

output "auth_string" {
  description = "Redis AUTH string"
  value       = google_redis_instance.this.auth_string
  sensitive   = true
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
