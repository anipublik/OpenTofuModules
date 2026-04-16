output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_eventhub_namespace.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_eventhub_namespace.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_eventhub_namespace.this.name
}

output "namespace_id" {
  description = "Event Hub namespace ID"
  value       = azurerm_eventhub_namespace.this.id
}

output "namespace_name" {
  description = "Event Hub namespace name"
  value       = azurerm_eventhub_namespace.this.name
}

output "default_primary_connection_string" {
  description = "Primary connection string"
  value       = azurerm_eventhub_namespace.this.default_primary_connection_string
  sensitive   = true
}

output "eventhub_ids" {
  description = "Map of Event Hub names to IDs"
  value       = { for k, v in azurerm_eventhub.this : v.name => v.id }
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
