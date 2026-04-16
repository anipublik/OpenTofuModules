resource "azurerm_log_analytics_workspace" "this" {
  name                = local.workspace_name
  location            = local.config.meta.region
  resource_group_name = local.config.azure.resource_group
  sku                 = lookup(local.config.workspace, "sku", "PerGB2018")
  retention_in_days   = lookup(local.config.workspace, "retention_days", 90)
  daily_quota_gb      = lookup(local.config.workspace, "daily_quota_gb", -1)

  internet_ingestion_enabled = lookup(local.config.workspace, "internet_ingestion_enabled", false)
  internet_query_enabled     = lookup(local.config.workspace, "internet_query_enabled", false)

  tags = local.tags
}

resource "azurerm_log_analytics_solution" "this" {
  for_each = toset(lookup(local.config.workspace, "solutions", []))

  solution_name         = each.value
  location              = local.config.meta.region
  resource_group_name   = local.config.azure.resource_group
  workspace_resource_id = azurerm_log_analytics_workspace.this.id
  workspace_name        = azurerm_log_analytics_workspace.this.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/${each.value}"
  }

  tags = local.tags
}

resource "azurerm_log_analytics_saved_search" "this" {
  for_each = { for idx, search in lookup(local.config.workspace, "saved_searches", []) : idx => search }

  name                       = each.value.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id
  category                   = lookup(each.value, "category", "General")
  display_name               = lookup(each.value, "display_name", each.value.name)
  query                      = each.value.query

  tags = local.tags
}
