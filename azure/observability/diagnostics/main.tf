resource "azurerm_monitor_diagnostic_setting" "this" {
  name                           = local.diagnostics_name
  target_resource_id             = local.config.diagnostics.target_resource_id
  log_analytics_workspace_id     = lookup(local.config.diagnostics, "log_analytics_workspace_id", null)
  storage_account_id             = lookup(local.config.diagnostics, "storage_account_id", null)
  eventhub_name                  = lookup(local.config.diagnostics, "eventhub_name", null)
  eventhub_authorization_rule_id = lookup(local.config.diagnostics, "eventhub_authorization_rule_id", null)

  dynamic "enabled_log" {
    for_each = lookup(local.config.diagnostics, "log_categories", [])
    content {
      category = enabled_log.value

      retention_policy {
        enabled = lookup(local.config.diagnostics, "retention_enabled", true)
        days    = lookup(local.config.diagnostics, "retention_days", 90)
      }
    }
  }

  dynamic "metric" {
    for_each = lookup(local.config.diagnostics, "metric_categories", ["AllMetrics"])
    content {
      category = metric.value
      enabled  = true

      retention_policy {
        enabled = lookup(local.config.diagnostics, "retention_enabled", true)
        days    = lookup(local.config.diagnostics, "retention_days", 90)
      }
    }
  }
}
