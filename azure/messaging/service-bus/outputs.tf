output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_servicebus_namespace.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_servicebus_namespace.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_servicebus_namespace.this.name
}

output "namespace_id" {
  description = "Service Bus namespace ID"
  value       = azurerm_servicebus_namespace.this.id
}

output "namespace_name" {
  description = "Service Bus namespace name"
  value       = azurerm_servicebus_namespace.this.name
}

output "default_primary_connection_string" {
  description = "Primary connection string"
  value       = azurerm_servicebus_namespace.this.default_primary_connection_string
  sensitive   = true
}

output "queue_ids" {
  description = "Map of queue names to IDs"
  value       = { for k, v in azurerm_servicebus_queue.this : v.name => v.id }
}

output "topic_ids" {
  description = "Map of topic names to IDs"
  value       = { for k, v in azurerm_servicebus_topic.this : v.name => v.id }
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
