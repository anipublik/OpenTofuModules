resource "azurerm_servicebus_namespace" "this" {
  name                = local.namespace_name
  location            = local.config.meta.region
  resource_group_name = local.config.azure.resource_group
  sku                 = lookup(local.config.servicebus, "sku", "Standard")
  capacity            = lookup(local.config.servicebus, "capacity", 0)

  zone_redundant = lookup(local.config.reliability, "zone_redundant", true)

  identity {
    type = "SystemAssigned"
  }

  network_rule_set {
    default_action                = local.config.security.public_access ? "Allow" : "Deny"
    trusted_services_allowed      = true
    public_network_access_enabled = local.config.security.public_access

    dynamic "network_rules" {
      for_each = lookup(local.config.networking, "subnet_ids", [])
      content {
        subnet_id = network_rules.value
      }
    }

    dynamic "ip_rules" {
      for_each = lookup(local.config.networking, "allowed_ip_ranges", [])
      content {
        ip_mask = ip_rules.value
      }
    }
  }

  tags = local.tags
}

resource "azurerm_servicebus_queue" "this" {
  for_each = { for idx, queue in lookup(local.config.servicebus, "queues", []) : idx => queue }

  name         = each.value.name
  namespace_id = azurerm_servicebus_namespace.this.id

  max_size_in_megabytes                   = lookup(each.value, "max_size_mb", 1024)
  default_message_ttl                     = lookup(each.value, "default_message_ttl", "P14D")
  lock_duration                           = lookup(each.value, "lock_duration", "PT1M")
  max_delivery_count                      = lookup(each.value, "max_delivery_count", 10)
  requires_duplicate_detection            = lookup(each.value, "requires_duplicate_detection", false)
  duplicate_detection_history_time_window = lookup(each.value, "duplicate_detection_window", "PT10M")
  enable_partitioning                     = lookup(each.value, "enable_partitioning", false)
  dead_lettering_on_message_expiration    = lookup(each.value, "dead_lettering_on_message_expiration", true)
}

resource "azurerm_servicebus_topic" "this" {
  for_each = { for idx, topic in lookup(local.config.servicebus, "topics", []) : idx => topic }

  name         = each.value.name
  namespace_id = azurerm_servicebus_namespace.this.id

  max_size_in_megabytes                   = lookup(each.value, "max_size_mb", 1024)
  default_message_ttl                     = lookup(each.value, "default_message_ttl", "P14D")
  requires_duplicate_detection            = lookup(each.value, "requires_duplicate_detection", false)
  duplicate_detection_history_time_window = lookup(each.value, "duplicate_detection_window", "PT10M")
  enable_partitioning                     = lookup(each.value, "enable_partitioning", false)
}

resource "azurerm_servicebus_subscription" "this" {
  for_each = merge([
    for topic_idx, topic in lookup(local.config.servicebus, "topics", []) : {
      for sub_idx, sub in lookup(topic, "subscriptions", []) : "${topic_idx}-${sub_idx}" => {
        topic_name = topic.name
        sub        = sub
      }
    }
  ]...)

  name                                 = each.value.sub.name
  topic_id                             = azurerm_servicebus_topic.this[split("-", each.key)[0]].id
  max_delivery_count                   = lookup(each.value.sub, "max_delivery_count", 10)
  lock_duration                        = lookup(each.value.sub, "lock_duration", "PT1M")
  default_message_ttl                  = lookup(each.value.sub, "default_message_ttl", "P14D")
  dead_lettering_on_message_expiration = lookup(each.value.sub, "dead_lettering_on_message_expiration", true)
}
