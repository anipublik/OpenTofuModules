output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_monitor_action_group.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_monitor_action_group.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_monitor_action_group.this.name
}

output "action_group_id" {
  description = "Action group ID"
  value       = azurerm_monitor_action_group.this.id
}

output "metric_alert_ids" {
  description = "Map of metric alert names to IDs"
  value       = { for k, v in azurerm_monitor_metric_alert.this : v.name => v.id }
}

output "activity_log_alert_ids" {
  description = "Map of activity log alert names to IDs"
  value       = { for k, v in azurerm_monitor_activity_log_alert.this : v.name => v.id }
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
