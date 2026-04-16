output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_redis_cache.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_redis_cache.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_redis_cache.this.name
}

output "redis_id" {
  description = "Redis cache ID"
  value       = azurerm_redis_cache.this.id
}

output "hostname" {
  description = "Redis hostname"
  value       = azurerm_redis_cache.this.hostname
}

output "ssl_port" {
  description = "Redis SSL port"
  value       = azurerm_redis_cache.this.ssl_port
}

output "primary_access_key" {
  description = "Primary access key"
  value       = azurerm_redis_cache.this.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "Primary connection string"
  value       = azurerm_redis_cache.this.primary_connection_string
  sensitive   = true
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
