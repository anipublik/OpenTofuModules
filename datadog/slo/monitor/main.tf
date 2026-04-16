resource "datadog_service_level_objective" "this" {
  name        = local.slo_name
  type        = "monitor"
  description = lookup(local.config.slo, "description", "")

  monitor_ids = local.config.slo.monitor_ids

  dynamic "thresholds" {
    for_each = local.config.slo.thresholds
    content {
      timeframe = thresholds.value.timeframe
      target    = thresholds.value.target
      warning   = lookup(thresholds.value, "warning", null)
    }
  }

  tags = local.tags
}
