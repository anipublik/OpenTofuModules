resource "azurerm_monitor_action_group" "this" {
  name                = local.alert_name
  resource_group_name = local.config.azure.resource_group
  short_name          = substr(local.alert_name, 0, 12)

  dynamic "email_receiver" {
    for_each = lookup(local.config.alert, "email_receivers", [])
    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.email_address
      use_common_alert_schema = lookup(email_receiver.value, "use_common_alert_schema", true)
    }
  }

  dynamic "sms_receiver" {
    for_each = lookup(local.config.alert, "sms_receivers", [])
    content {
      name         = sms_receiver.value.name
      country_code = sms_receiver.value.country_code
      phone_number = sms_receiver.value.phone_number
    }
  }

  dynamic "webhook_receiver" {
    for_each = lookup(local.config.alert, "webhook_receivers", [])
    content {
      name                    = webhook_receiver.value.name
      service_uri             = webhook_receiver.value.service_uri
      use_common_alert_schema = lookup(webhook_receiver.value, "use_common_alert_schema", true)
    }
  }

  tags = local.tags
}

resource "azurerm_monitor_metric_alert" "this" {
  for_each = { for idx, alert in lookup(local.config.alert, "metric_alerts", []) : idx => alert }

  name                = "${local.alert_name}-${each.value.name}"
  resource_group_name = local.config.azure.resource_group
  scopes              = each.value.scopes
  description         = lookup(each.value, "description", "")
  severity            = lookup(each.value, "severity", 3)
  enabled             = lookup(each.value, "enabled", true)
  auto_mitigate       = lookup(each.value, "auto_mitigate", true)
  frequency           = lookup(each.value, "frequency", "PT1M")
  window_size         = lookup(each.value, "window_size", "PT5M")

  criteria {
    metric_namespace = each.value.metric_namespace
    metric_name      = each.value.metric_name
    aggregation      = each.value.aggregation
    operator         = each.value.operator
    threshold        = each.value.threshold

    dynamic "dimension" {
      for_each = lookup(each.value, "dimensions", [])
      content {
        name     = dimension.value.name
        operator = dimension.value.operator
        values   = dimension.value.values
      }
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }

  tags = local.tags
}

resource "azurerm_monitor_activity_log_alert" "this" {
  for_each = { for idx, alert in lookup(local.config.alert, "activity_log_alerts", []) : idx => alert }

  name                = "${local.alert_name}-${each.value.name}"
  resource_group_name = local.config.azure.resource_group
  scopes              = each.value.scopes
  description         = lookup(each.value, "description", "")
  enabled             = lookup(each.value, "enabled", true)

  criteria {
    category       = each.value.category
    operation_name = lookup(each.value, "operation_name", null)
    resource_type  = lookup(each.value, "resource_type", null)
    resource_group = lookup(each.value, "resource_group", null)
    level          = lookup(each.value, "level", null)
    status         = lookup(each.value, "status", null)
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }

  tags = local.tags
}
