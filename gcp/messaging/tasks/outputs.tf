output "resource_id" {
  description = "Resource identifier"
  value       = google_cloud_tasks_queue.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = google_cloud_tasks_queue.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = google_cloud_tasks_queue.this.name
}

output "queue_id" {
  description = "Cloud Tasks queue ID"
  value       = google_cloud_tasks_queue.this.id
}

output "queue_name" {
  description = "Cloud Tasks queue name"
  value       = google_cloud_tasks_queue.this.name
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
