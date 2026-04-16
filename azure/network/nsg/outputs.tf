output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_network_security_group.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_network_security_group.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_network_security_group.this.name
}

output "nsg_id" {
  description = "Network security group ID"
  value       = azurerm_network_security_group.this.id
}

output "nsg_name" {
  description = "Network security group name"
  value       = azurerm_network_security_group.this.name
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
