resource "datadog_monitor" "this" {
  name    = local.monitor_name
  type    = lookup(local.config.monitor, "type", "metric alert")
  query   = local.config.monitor.query
  message = local.config.monitor.message

  monitor_thresholds {
    critical          = lookup(local.config.monitor.thresholds, "critical", null)
    critical_recovery = lookup(local.config.monitor.thresholds, "critical_recovery", null)
    warning           = lookup(local.config.monitor.thresholds, "warning", null)
    warning_recovery  = lookup(local.config.monitor.thresholds, "warning_recovery", null)
  }

  evaluation_delay    = lookup(local.config.monitor, "evaluation_delay", null)
  new_group_delay     = lookup(local.config.monitor, "new_group_delay", 300)
  notify_no_data      = lookup(local.config.monitor, "notify_no_data", true)
  no_data_timeframe   = lookup(local.config.monitor, "no_data_timeframe", 10)
  renotify_interval   = lookup(local.config.monitor, "renotify_interval", 0)
  require_full_window = lookup(local.config.monitor, "require_full_window", false)
  include_tags        = lookup(local.config.monitor, "include_tags", true)

  tags = local.tags
}
