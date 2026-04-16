resource "azurerm_eventhub_namespace" "this" {
  name                = local.namespace_name
  location            = local.config.meta.region
  resource_group_name = local.config.azure.resource_group
  sku                 = lookup(local.config.eventhub, "sku", "Standard")
  capacity            = lookup(local.config.eventhub, "capacity", 1)

  auto_inflate_enabled     = lookup(local.config.eventhub, "auto_inflate_enabled", false)
  maximum_throughput_units = lookup(local.config.eventhub, "maximum_throughput_units", null)

  zone_redundant = lookup(local.config.reliability, "zone_redundant", true)

  identity {
    type = "SystemAssigned"
  }

  network_rulesets {
    default_action                 = local.config.security.public_access ? "Allow" : "Deny"
    trusted_service_access_enabled = true

    dynamic "ip_rule" {
      for_each = lookup(local.config.networking, "allowed_ip_ranges", [])
      content {
        ip_mask = ip_rule.value
      }
    }

    dynamic "virtual_network_rule" {
      for_each = lookup(local.config.networking, "subnet_ids", [])
      content {
        subnet_id = virtual_network_rule.value
      }
    }
  }

  tags = local.tags
}

resource "azurerm_eventhub" "this" {
  for_each = { for idx, hub in lookup(local.config.eventhub, "hubs", []) : idx => hub }

  name                = each.value.name
  namespace_name      = azurerm_eventhub_namespace.this.name
  resource_group_name = local.config.azure.resource_group
  partition_count     = lookup(each.value, "partition_count", 2)
  message_retention   = lookup(each.value, "message_retention", 1)

  capture_description {
    enabled             = lookup(each.value, "capture_enabled", false)
    encoding            = "Avro"
    interval_in_seconds = lookup(each.value, "capture_interval", 300)
    size_limit_in_bytes = lookup(each.value, "capture_size_limit", 314572800)

    destination {
      name                = "EventHubArchive.AzureBlockBlob"
      archive_name_format = "{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
      blob_container_name = lookup(each.value, "capture_container", "eventhub-capture")
      storage_account_id  = lookup(each.value, "capture_storage_account_id", null)
    }
  }
}

resource "azurerm_eventhub_consumer_group" "this" {
  for_each = merge([
    for hub_idx, hub in lookup(local.config.eventhub, "hubs", []) : {
      for cg_idx, cg in lookup(hub, "consumer_groups", []) : "${hub_idx}-${cg_idx}" => {
        hub_name = hub.name
        cg_name  = cg
      }
    }
  ]...)

  name                = each.value.cg_name
  namespace_name      = azurerm_eventhub_namespace.this.name
  eventhub_name       = azurerm_eventhub.this[split("-", each.key)[0]].name
  resource_group_name = local.config.azure.resource_group
}
