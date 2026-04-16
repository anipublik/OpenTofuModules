output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_log_analytics_workspace.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_log_analytics_workspace.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_log_analytics_workspace.this.name
}

output "workspace_id" {
  description = "Log Analytics workspace ID"
  value       = azurerm_log_analytics_workspace.this.workspace_id
}

output "workspace_resource_id" {
  description = "Log Analytics workspace resource ID"
  value       = azurerm_log_analytics_workspace.this.id
}

output "primary_shared_key" {
  description = "Primary shared key"
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
