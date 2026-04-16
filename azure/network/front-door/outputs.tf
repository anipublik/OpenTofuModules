output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_cdn_frontdoor_profile.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_cdn_frontdoor_profile.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_cdn_frontdoor_profile.this.name
}

output "frontdoor_id" {
  description = "Front Door profile ID"
  value       = azurerm_cdn_frontdoor_profile.this.id
}

output "endpoint_ids" {
  description = "Map of endpoint names to IDs"
  value       = { for k, v in azurerm_cdn_frontdoor_endpoint.this : v.name => v.id }
}

output "endpoint_hostnames" {
  description = "Map of endpoint names to hostnames"
  value       = { for k, v in azurerm_cdn_frontdoor_endpoint.this : v.name => v.host_name }
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
