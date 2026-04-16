output "resource_id" {
  description = "Resource identifier"
  value       = google_compute_instance.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = google_compute_instance.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = google_compute_instance.this.name
}

output "instance_id" {
  description = "GCE instance ID"
  value       = google_compute_instance.this.instance_id
}

output "instance_self_link" {
  description = "GCE instance self link"
  value       = google_compute_instance.this.self_link
}

output "private_ip" {
  description = "Private IP address"
  value       = google_compute_instance.this.network_interface[0].network_ip
}

output "public_ip" {
  description = "Public IP address"
  value       = length(google_compute_instance.this.network_interface[0].access_config) > 0 ? google_compute_instance.this.network_interface[0].access_config[0].nat_ip : null
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
