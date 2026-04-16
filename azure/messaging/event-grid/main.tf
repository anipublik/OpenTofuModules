resource "azurerm_eventgrid_topic" "this" {
  name                = local.topic_name
  location            = local.config.meta.region
  resource_group_name = local.config.azure.resource_group

  input_schema = lookup(local.config.topic, "input_schema", "EventGridSchema")

  public_network_access_enabled = local.config.security.public_access

  dynamic "input_mapping_fields" {
    for_each = lookup(local.config.topic, "input_mapping_fields", null) != null ? [1] : []
    content {
      id           = lookup(local.config.topic.input_mapping_fields, "id", null)
      topic        = lookup(local.config.topic.input_mapping_fields, "topic", null)
      event_time   = lookup(local.config.topic.input_mapping_fields, "event_time", null)
      event_type   = lookup(local.config.topic.input_mapping_fields, "event_type", null)
      subject      = lookup(local.config.topic.input_mapping_fields, "subject", null)
      data_version = lookup(local.config.topic.input_mapping_fields, "data_version", null)
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_eventgrid_event_subscription" "this" {
  for_each = { for idx, sub in lookup(local.config.topic, "subscriptions", []) : idx => sub }

  name  = each.value.name
  scope = azurerm_eventgrid_topic.this.id

  dynamic "webhook_endpoint" {
    for_each = lookup(each.value, "webhook_endpoint", null) != null ? [1] : []
    content {
      url = each.value.webhook_endpoint.url
    }
  }

  dynamic "storage_queue_endpoint" {
    for_each = lookup(each.value, "storage_queue_endpoint", null) != null ? [1] : []
    content {
      storage_account_id = each.value.storage_queue_endpoint.storage_account_id
      queue_name         = each.value.storage_queue_endpoint.queue_name
    }
  }

  dynamic "eventhub_endpoint_id" {
    for_each = lookup(each.value, "eventhub_endpoint_id", null) != null ? [1] : []
    content {
      eventhub_id = each.value.eventhub_endpoint_id
    }
  }

  dynamic "subject_filter" {
    for_each = lookup(each.value, "subject_filter", null) != null ? [1] : []
    content {
      subject_begins_with = lookup(each.value.subject_filter, "subject_begins_with", null)
      subject_ends_with   = lookup(each.value.subject_filter, "subject_ends_with", null)
      case_sensitive      = lookup(each.value.subject_filter, "case_sensitive", false)
    }
  }

  included_event_types = lookup(each.value, "included_event_types", null)

  retry_policy {
    max_delivery_attempts = lookup(each.value, "max_delivery_attempts", 30)
    event_time_to_live    = lookup(each.value, "event_time_to_live", 1440)
  }
}
