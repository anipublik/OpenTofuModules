output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_eventgrid_topic.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_eventgrid_topic.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_eventgrid_topic.this.name
}

output "topic_id" {
  description = "Event Grid topic ID"
  value       = azurerm_eventgrid_topic.this.id
}

output "topic_endpoint" {
  description = "Event Grid topic endpoint"
  value       = azurerm_eventgrid_topic.this.endpoint
}

output "primary_access_key" {
  description = "Primary access key"
  value       = azurerm_eventgrid_topic.this.primary_access_key
  sensitive   = true
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
