output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_application_gateway.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_application_gateway.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_application_gateway.this.name
}

output "app_gateway_id" {
  description = "Application Gateway ID"
  value       = azurerm_application_gateway.this.id
}

output "public_ip_address" {
  description = "Public IP address"
  value       = azurerm_public_ip.this.ip_address
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
