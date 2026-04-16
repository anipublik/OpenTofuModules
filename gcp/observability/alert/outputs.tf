output "resource_id" {
  description = "Resource identifier (first alert policy; null if none defined)"
  value       = length(google_monitoring_alert_policy.this) > 0 ? values(google_monitoring_alert_policy.this)[0].id : null
}

output "resource_arn" {
  description = "Resource ARN or equivalent (first alert policy; null if none defined)"
  value       = length(google_monitoring_alert_policy.this) > 0 ? values(google_monitoring_alert_policy.this)[0].name : null
}

output "alert_policy_ids" {
  description = "Map of alert policy names to IDs"
  value       = { for k, v in google_monitoring_alert_policy.this : v.display_name => v.id }
}

output "notification_channel_ids" {
  description = "Map of notification channel names to IDs"
  value       = { for k, v in google_monitoring_notification_channel.this : v.display_name => v.id }
}

output "resource_name" {
  description = "Resource name"
  value       = local.resource_name
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
