resource "datadog_logs_index" "this" {
  name = local.index_name

  filter {
    query = local.config.index.filter
  }

  dynamic "exclusion_filter" {
    for_each = lookup(local.config.index, "exclusion_filters", [])
    content {
      name       = exclusion_filter.value.name
      is_enabled = lookup(exclusion_filter.value, "enabled", true)
      filter {
        query       = exclusion_filter.value.query
        sample_rate = lookup(exclusion_filter.value, "sample_rate", 1.0)
      }
    }
  }

  retention_days        = lookup(local.config.index, "retention_days", 15)
  daily_limit           = lookup(local.config.index, "daily_limit", null)
  disable_daily_limit   = lookup(local.config.index, "disable_daily_limit", false)
}
