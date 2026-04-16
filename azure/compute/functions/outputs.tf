output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_linux_function_app.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_linux_function_app.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_linux_function_app.this.name
}

output "function_app_id" {
  description = "Function App ID"
  value       = azurerm_linux_function_app.this.id
}

output "default_hostname" {
  description = "Function App default hostname"
  value       = azurerm_linux_function_app.this.default_hostname
}

output "outbound_ip_addresses" {
  description = "Outbound IP addresses"
  value       = azurerm_linux_function_app.this.outbound_ip_addresses
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
