output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_container_app.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_container_app.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_container_app.this.name
}

output "container_app_id" {
  description = "Container App ID"
  value       = azurerm_container_app.this.id
}

output "container_app_fqdn" {
  description = "Container App FQDN"
  value       = azurerm_container_app.this.latest_revision_fqdn
}

output "environment_id" {
  description = "Container App Environment ID"
  value       = azurerm_container_app_environment.this.id
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
