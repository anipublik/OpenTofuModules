resource "datadog_service_level_objective" "this" {
  name        = local.slo_name
  type        = "metric"
  description = lookup(local.config.slo, "description", "")

  query {
    numerator   = local.config.slo.query.numerator
    denominator = local.config.slo.query.denominator
  }

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
