output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_mssql_database.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_mssql_database.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_mssql_database.this.name
}

output "server_id" {
  description = "SQL Server ID"
  value       = azurerm_mssql_server.this.id
}

output "server_fqdn" {
  description = "SQL Server FQDN"
  value       = azurerm_mssql_server.this.fully_qualified_domain_name
}

output "database_id" {
  description = "SQL Database ID"
  value       = azurerm_mssql_database.this.id
}

output "database_name" {
  description = "SQL Database name"
  value       = azurerm_mssql_database.this.name
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
