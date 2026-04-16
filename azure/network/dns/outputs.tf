output "resource_id" {
  description = "Resource identifier"
  value       = length(azurerm_dns_zone.this) > 0 ? azurerm_dns_zone.this[0].id : null
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = length(azurerm_dns_zone.this) > 0 ? azurerm_dns_zone.this[0].id : null
}

output "resource_name" {
  description = "Resource name"
  value       = length(azurerm_dns_zone.this) > 0 ? azurerm_dns_zone.this[0].name : null
}

output "zone_id" {
  description = "DNS zone ID"
  value       = length(azurerm_dns_zone.this) > 0 ? azurerm_dns_zone.this[0].id : null
}

output "name_servers" {
  description = "DNS zone name servers"
  value       = length(azurerm_dns_zone.this) > 0 ? azurerm_dns_zone.this[0].name_servers : []
}

output "private_zone_id" {
  description = "Private DNS zone ID"
  value       = length(azurerm_private_dns_zone.this) > 0 ? azurerm_private_dns_zone.this[0].id : null
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
