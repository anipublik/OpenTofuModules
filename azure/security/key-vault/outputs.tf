output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_key_vault.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_key_vault.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_key_vault.this.name
}

output "key_vault_id" {
  description = "Key Vault ID"
  value       = azurerm_key_vault.this.id
}

output "key_vault_uri" {
  description = "Key Vault URI"
  value       = azurerm_key_vault.this.vault_uri
}

output "secret_ids" {
  description = "Map of secret names to IDs"
  value       = { for k, v in azurerm_key_vault_secret.this : v.name => v.id }
}

output "key_ids" {
  description = "Map of key names to IDs"
  value       = { for k, v in azurerm_key_vault_key.this : v.name => v.id }
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
