output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_user_assigned_identity.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_user_assigned_identity.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_user_assigned_identity.this.name
}

output "identity_id" {
  description = "Managed identity ID"
  value       = azurerm_user_assigned_identity.this.id
}

output "principal_id" {
  description = "Managed identity principal ID"
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "client_id" {
  description = "Managed identity client ID"
  value       = azurerm_user_assigned_identity.this.client_id
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
