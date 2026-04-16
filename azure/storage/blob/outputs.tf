output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_storage_account.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_storage_account.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_storage_account.this.name
}

output "storage_account_id" {
  description = "Storage account ID"
  value       = azurerm_storage_account.this.id
}

output "storage_account_name" {
  description = "Storage account name"
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_access_key" {
  description = "Primary access key"
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "container_ids" {
  description = "Map of container names to IDs"
  value       = { for k, v in azurerm_storage_container.this : v.name => v.id }
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
