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
    ok                = lookup(local.config.monitor.thresholds, "ok", null)
  }

  evaluation_delay    = lookup(local.config.monitor, "evaluation_delay", null)
  new_group_delay     = lookup(local.config.monitor, "new_group_delay", null)
  notify_no_data      = lookup(local.config.monitor, "notify_no_data", false)
  no_data_timeframe   = lookup(local.config.monitor, "no_data_timeframe", null)
  renotify_interval   = lookup(local.config.monitor, "renotify_interval", 0)
  notify_audit        = lookup(local.config.monitor, "notify_audit", false)
  timeout_h           = lookup(local.config.monitor, "timeout_h", 0)
  include_tags        = lookup(local.config.monitor, "include_tags", true)
  require_full_window = lookup(local.config.monitor, "require_full_window", true)
  locked              = lookup(local.config.monitor, "locked", false)

  priority = lookup(local.config.monitor, "priority", null)

  tags = local.tags
}
