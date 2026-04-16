output "resource_id" {
  description = "Resource identifier"
  value       = google_container_cluster.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = google_container_cluster.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = google_container_cluster.this.name
}

output "cluster_id" {
  description = "GKE cluster ID"
  value       = google_container_cluster.this.id
}

output "cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.this.name
}

output "endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.this.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = google_container_cluster.this.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
