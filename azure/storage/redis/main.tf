resource "azurerm_redis_cache" "this" {
  name                = local.redis_name
  location            = local.config.meta.region
  resource_group_name = local.config.azure.resource_group
  capacity            = lookup(local.config.redis, "capacity", 1)
  family              = lookup(local.config.redis, "family", "C")
  sku_name            = lookup(local.config.redis, "sku_name", "Standard")

  enable_non_ssl_port           = false
  minimum_tls_version           = "1.2"
  public_network_access_enabled = local.config.security.public_access

  redis_configuration {
    enable_authentication           = true
    maxmemory_reserved              = lookup(local.config.redis, "maxmemory_reserved", null)
    maxmemory_delta                 = lookup(local.config.redis, "maxmemory_delta", null)
    maxmemory_policy                = lookup(local.config.redis, "maxmemory_policy", "allkeys-lru")
    maxfragmentationmemory_reserved = lookup(local.config.redis, "maxfragmentationmemory_reserved", null)
    rdb_backup_enabled              = lookup(local.config.reliability, "backup_enabled", false)
    rdb_backup_frequency            = lookup(local.config.reliability, "backup_frequency", 60)
    rdb_backup_max_snapshot_count   = lookup(local.config.reliability, "backup_max_snapshots", 1)
    rdb_storage_connection_string   = lookup(local.config.reliability, "backup_storage_connection_string", null)
  }

  zone_redundant = lookup(local.config.reliability, "zone_redundant", false)
  replicas_per_master = lookup(local.config.redis, "replicas_per_master", 0)

  patch_schedule {
    day_of_week    = lookup(local.config.redis, "patch_day", "Sunday")
    start_hour_utc = lookup(local.config.redis, "patch_hour", 2)
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_redis_firewall_rule" "this" {
  for_each = { for idx, rule in lookup(local.config.networking, "firewall_rules", []) : idx => rule }

  name                = each.value.name
  redis_cache_name    = azurerm_redis_cache.this.name
  resource_group_name = local.config.azure.resource_group
  start_ip            = each.value.start_ip
  end_ip              = each.value.end_ip
}
