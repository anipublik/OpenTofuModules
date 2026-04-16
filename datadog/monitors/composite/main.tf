resource "datadog_monitor" "this" {
  name    = local.monitor_name
  type    = "composite"
  query   = local.config.monitor.query
  message = local.config.monitor.message

  renotify_interval = lookup(local.config.monitor, "renotify_interval", 0)
  notify_no_data    = lookup(local.config.monitor, "notify_no_data", false)
  include_tags      = lookup(local.config.monitor, "include_tags", true)
  locked            = lookup(local.config.monitor, "locked", false)

  tags = local.tags
}
