output "resource_id" {
  description = "Resource identifier"
  value       = length(azurerm_policy_definition.this) > 0 ? azurerm_policy_definition.this[0].id : (length(azurerm_resource_group_policy_assignment.this) > 0 ? azurerm_resource_group_policy_assignment.this[0].id : (length(azurerm_subscription_policy_assignment.this) > 0 ? azurerm_subscription_policy_assignment.this[0].id : null))
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = length(azurerm_policy_definition.this) > 0 ? azurerm_policy_definition.this[0].id : (length(azurerm_resource_group_policy_assignment.this) > 0 ? azurerm_resource_group_policy_assignment.this[0].id : (length(azurerm_subscription_policy_assignment.this) > 0 ? azurerm_subscription_policy_assignment.this[0].id : null))
}

output "policy_definition_id" {
  description = "Policy definition ID"
  value       = length(azurerm_policy_definition.this) > 0 ? azurerm_policy_definition.this[0].id : null
}

output "policy_assignment_id" {
  description = "Policy assignment ID"
  value       = length(azurerm_resource_group_policy_assignment.this) > 0 ? azurerm_resource_group_policy_assignment.this[0].id : (length(azurerm_subscription_policy_assignment.this) > 0 ? azurerm_subscription_policy_assignment.this[0].id : null)
}

output "resource_name" {
  description = "Resource name"
  value       = local.resource_name
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
