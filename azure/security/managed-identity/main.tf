resource "azurerm_user_assigned_identity" "this" {
  name                = local.identity_name
  location            = local.config.meta.region
  resource_group_name = local.config.azure.resource_group

  tags = local.tags
}

resource "azurerm_role_assignment" "this" {
  for_each = { for idx, role in lookup(local.config.identity, "role_assignments", []) : idx => role }

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = azurerm_user_assigned_identity.this.principal_id
}
