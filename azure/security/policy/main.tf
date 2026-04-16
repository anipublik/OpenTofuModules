resource "azurerm_policy_definition" "this" {
  count = lookup(local.config.policy, "create_definition", false) ? 1 : 0

  name         = local.policy_name
  policy_type  = "Custom"
  mode         = lookup(local.config.policy, "mode", "All")
  display_name = lookup(local.config.policy, "display_name", local.policy_name)
  description  = lookup(local.config.policy, "description", "")

  metadata = jsonencode({
    category = lookup(local.config.policy, "category", "General")
  })

  policy_rule = jsonencode(local.config.policy.policy_rule)
  parameters  = lookup(local.config.policy, "parameters", null) != null ? jsonencode(local.config.policy.parameters) : null
}

resource "azurerm_resource_group_policy_assignment" "this" {
  count = lookup(local.config.policy, "assign_to_resource_group", false) ? 1 : 0

  name                 = "${local.policy_name}-assignment"
  resource_group_id    = local.config.azure.resource_group_id
  policy_definition_id = lookup(local.config.policy, "create_definition", false) ? azurerm_policy_definition.this[0].id : local.config.policy.policy_definition_id

  description  = lookup(local.config.policy, "assignment_description", "")
  display_name = lookup(local.config.policy, "assignment_display_name", "${local.policy_name} Assignment")
  enforce      = lookup(local.config.policy, "enforce", true)

  parameters = lookup(local.config.policy, "assignment_parameters", null) != null ? jsonencode(local.config.policy.assignment_parameters) : null

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_subscription_policy_assignment" "this" {
  count = lookup(local.config.policy, "assign_to_subscription", false) ? 1 : 0

  name                 = "${local.policy_name}-assignment"
  subscription_id      = local.config.azure.subscription_id
  policy_definition_id = lookup(local.config.policy, "create_definition", false) ? azurerm_policy_definition.this[0].id : local.config.policy.policy_definition_id

  description  = lookup(local.config.policy, "assignment_description", "")
  display_name = lookup(local.config.policy, "assignment_display_name", "${local.policy_name} Assignment")
  enforce      = lookup(local.config.policy, "enforce", true)

  parameters = lookup(local.config.policy, "assignment_parameters", null) != null ? jsonencode(local.config.policy.assignment_parameters) : null

  identity {
    type = "SystemAssigned"
  }
}
