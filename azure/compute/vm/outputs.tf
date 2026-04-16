output "resource_id" {
  description = "Resource identifier"
  value       = azurerm_linux_virtual_machine_scale_set.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = azurerm_linux_virtual_machine_scale_set.this.id
}

output "resource_name" {
  description = "Resource name"
  value       = azurerm_linux_virtual_machine_scale_set.this.name
}

output "vmss_id" {
  description = "Virtual machine scale set ID"
  value       = azurerm_linux_virtual_machine_scale_set.this.id
}

output "vmss_unique_id" {
  description = "Virtual machine scale set unique ID"
  value       = azurerm_linux_virtual_machine_scale_set.this.unique_id
}

output "principal_id" {
  description = "System assigned identity principal ID"
  value       = azurerm_linux_virtual_machine_scale_set.this.identity[0].principal_id
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
