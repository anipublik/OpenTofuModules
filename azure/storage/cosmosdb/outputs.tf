output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_cosmosdb_account.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_cosmosdb_account.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_cosmosdb_account.this.name
}

output "account_id" {
  description = "Cosmos DB account ID"
  value       = azurerm_cosmosdb_account.this.id
}

output "endpoint" {
  description = "Cosmos DB endpoint"
  value       = azurerm_cosmosdb_account.this.endpoint
}

output "primary_key" {
  description = "Primary master key"
  value       = azurerm_cosmosdb_account.this.primary_key
  sensitive   = true
}

output "connection_strings" {
  description = "Connection strings"
  value       = azurerm_cosmosdb_account.this.connection_strings
  sensitive   = true
}

output "database_ids" {
  description = "Map of database names to IDs"
  value       = { for k, v in azurerm_cosmosdb_sql_database.this : v.name => v.id }
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
