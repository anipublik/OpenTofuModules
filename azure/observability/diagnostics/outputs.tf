output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_monitor_diagnostic_setting.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_monitor_diagnostic_setting.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_monitor_diagnostic_setting.this.name
}

output "diagnostic_setting_id" {
  description = "Diagnostic setting ID"
  value       = azurerm_monitor_diagnostic_setting.this.id
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
