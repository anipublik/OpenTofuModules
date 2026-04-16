output "resource_id" {
  description = "Resource identifier"
  value       = google_pubsub_topic.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = google_pubsub_topic.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = google_pubsub_topic.this.name
}

output "topic_id" {
  description = "Pub/Sub topic ID"
  value       = google_pubsub_topic.this.id
}

output "topic_name" {
  description = "Pub/Sub topic name"
  value       = google_pubsub_topic.this.name
}

output "subscription_ids" {
  description = "Map of subscription names to IDs"
  value       = { for k, v in google_pubsub_subscription.this : v.name => v.id }
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
