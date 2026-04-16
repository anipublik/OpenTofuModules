resource "azurerm_virtual_network" "this" {
  name                = local.vnet_name
  location            = local.config.meta.region
  resource_group_name = local.config.azure.resource_group
  address_space       = local.config.network.address_space

  tags = local.tags
}

resource "azurerm_subnet" "this" {
  for_each = { for idx, subnet in local.config.network.subnets : idx => subnet }

  name                 = each.value.name
  resource_group_name  = local.config.azure.resource_group
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.address_prefix]

  service_endpoints = lookup(each.value, "service_endpoints", [
    "Microsoft.Storage",
    "Microsoft.Sql",
    "Microsoft.KeyVault",
    "Microsoft.ContainerRegistry"
  ])
}

resource "azurerm_network_security_group" "this" {
  for_each = { for idx, subnet in local.config.network.subnets : idx => subnet }

  name                = "${each.value.name}-nsg"
  location            = local.config.meta.region
  resource_group_name = local.config.azure.resource_group

  tags = local.tags
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = { for idx, subnet in local.config.network.subnets : idx => subnet }

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

resource "azurerm_network_watcher_flow_log" "this" {
  count = local.config.security.flow_logs_enabled ? 1 : 0

  network_watcher_name = "NetworkWatcher_${local.config.meta.region}"
  resource_group_name  = "NetworkWatcherRG"
  name                 = "${local.vnet_name}-flow-log"

  network_security_group_id = azurerm_network_security_group.this[0].id
  storage_account_id        = lookup(local.config.network, "flow_logs_storage_account_id", null)
  enabled                   = true

  retention_policy {
    enabled = true
    days    = 90
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = lookup(local.config.network, "log_analytics_workspace_id", null)
    workspace_region      = local.config.meta.region
    workspace_resource_id = lookup(local.config.network, "log_analytics_workspace_resource_id", null)
    interval_in_minutes   = 10
  }

  tags = local.tags
}
