output "resource_id" {
  description = "Resource identifier"
  value       = google_compute_network.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = google_compute_network.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = google_compute_network.this.name
}

output "network_id" {
  description = "VPC network ID"
  value       = google_compute_network.this.id
}

output "network_name" {
  description = "VPC network name"
  value       = google_compute_network.this.name
}

output "network_self_link" {
  description = "VPC network self link"
  value       = google_compute_network.this.self_link
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = { for k, v in google_compute_subnetwork.this : v.name => v.id }
}

output "subnet_self_links" {
  description = "Map of subnet names to self links"
  value       = { for k, v in google_compute_subnetwork.this : v.name => v.self_link }
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
