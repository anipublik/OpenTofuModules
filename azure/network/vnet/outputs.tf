output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_virtual_network.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_virtual_network.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_virtual_network.this.name
}

output "vnet_id" {
  description = "Virtual network ID"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Virtual network name"
  value       = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value       = { for k, v in azurerm_subnet.this : v.name => v.id }
}

output "nsg_ids" {
  description = "Map of NSG names to IDs"
  value       = { for k, v in azurerm_network_security_group.this : v.name => v.id }
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
