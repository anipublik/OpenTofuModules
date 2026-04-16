resource "azurerm_cosmosdb_account" "this" {
  name                = local.account_name
  location            = local.config.meta.region
  resource_group_name = local.config.azure.resource_group
  offer_type          = "Standard"
  kind                = lookup(local.config.cosmosdb, "kind", "GlobalDocumentDB")

  consistency_policy {
    consistency_level       = lookup(local.config.cosmosdb, "consistency_level", "Session")
    max_interval_in_seconds = lookup(local.config.cosmosdb, "max_interval_in_seconds", 5)
    max_staleness_prefix    = lookup(local.config.cosmosdb, "max_staleness_prefix", 100)
  }

  geo_location {
    location          = local.config.meta.region
    failover_priority = 0
    zone_redundant    = lookup(local.config.reliability, "zone_redundant", true)
  }

  dynamic "geo_location" {
    for_each = lookup(local.config.cosmosdb, "additional_locations", [])
    content {
      location          = geo_location.value.location
      failover_priority = geo_location.value.failover_priority
      zone_redundant    = lookup(geo_location.value, "zone_redundant", false)
    }
  }

  enable_automatic_failover = lookup(local.config.cosmosdb, "enable_automatic_failover", true)
  enable_multiple_write_locations = lookup(local.config.cosmosdb, "enable_multiple_write_locations", false)

  public_network_access_enabled = local.config.security.public_access
  is_virtual_network_filter_enabled = !local.config.security.public_access

  dynamic "virtual_network_rule" {
    for_each = lookup(local.config.networking, "subnet_ids", [])
    content {
      id = virtual_network_rule.value
    }
  }

  ip_range_filter = join(",", lookup(local.config.networking, "allowed_ip_ranges", []))

  backup {
    type                = lookup(local.config.cosmosdb, "backup_type", "Periodic")
    interval_in_minutes = lookup(local.config.cosmosdb, "backup_interval_minutes", 240)
    retention_in_hours  = lookup(local.config.cosmosdb, "backup_retention_hours", 8)
    storage_redundancy  = lookup(local.config.cosmosdb, "backup_storage_redundancy", "Geo")
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_cosmosdb_sql_database" "this" {
  for_each = { for idx, db in lookup(local.config.cosmosdb, "databases", []) : idx => db }

  name                = each.value.name
  resource_group_name = local.config.azure.resource_group
  account_name        = azurerm_cosmosdb_account.this.name
  throughput          = lookup(each.value, "throughput", null)

  dynamic "autoscale_settings" {
    for_each = lookup(each.value, "autoscale_max_throughput", null) != null ? [1] : []
    content {
      max_throughput = each.value.autoscale_max_throughput
    }
  }
}

resource "azurerm_cosmosdb_sql_container" "this" {
  for_each = merge([
    for db_idx, db in lookup(local.config.cosmosdb, "databases", []) : {
      for cont_idx, cont in lookup(db, "containers", []) : "${db_idx}-${cont_idx}" => {
        db_name   = db.name
        container = cont
      }
    }
  ]...)

  name                = each.value.container.name
  resource_group_name = local.config.azure.resource_group
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_sql_database.this[split("-", each.key)[0]].name
  partition_key_path  = each.value.container.partition_key_path
  throughput          = lookup(each.value.container, "throughput", null)

  indexing_policy {
    indexing_mode = lookup(each.value.container, "indexing_mode", "consistent")
  }
}
