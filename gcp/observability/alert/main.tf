resource "google_monitoring_alert_policy" "this" {
  for_each = { for idx, alert in local.config.alerts : idx => alert }

  display_name = "${local.alert_name}-${each.value.name}"
  project      = local.config.gcp.project_id
  combiner     = lookup(each.value, "combiner", "OR")
  enabled      = lookup(each.value, "enabled", true)

  conditions {
    display_name = each.value.condition.display_name

    condition_threshold {
      filter          = each.value.condition.filter
      duration        = lookup(each.value.condition, "duration", "60s")
      comparison      = lookup(each.value.condition, "comparison", "COMPARISON_GT")
      threshold_value = each.value.condition.threshold_value

      aggregations {
        alignment_period     = lookup(each.value.condition.aggregation, "alignment_period", "60s")
        per_series_aligner   = lookup(each.value.condition.aggregation, "per_series_aligner", "ALIGN_RATE")
        cross_series_reducer = lookup(each.value.condition.aggregation, "cross_series_reducer", "REDUCE_SUM")
        group_by_fields      = lookup(each.value.condition.aggregation, "group_by_fields", [])
      }

      dynamic "trigger" {
        for_each = lookup(each.value.condition, "trigger_count", null) != null ? [1] : []
        content {
          count = each.value.condition.trigger_count
        }
      }

      dynamic "trigger" {
        for_each = lookup(each.value.condition, "trigger_percent", null) != null ? [1] : []
        content {
          percent = each.value.condition.trigger_percent
        }
      }
    }
  }

  notification_channels = lookup(each.value, "notification_channels", [])

  alert_strategy {
    auto_close = lookup(each.value, "auto_close", "1800s")

    dynamic "notification_rate_limit" {
      for_each = lookup(each.value, "notification_rate_limit", null) != null ? [1] : []
      content {
        period = each.value.notification_rate_limit.period
      }
    }
  }

  documentation {
    content   = lookup(each.value, "documentation", "Alert triggered for ${each.value.name}")
    mime_type = "text/markdown"
  }

  user_labels = local.labels
}

resource "google_monitoring_notification_channel" "this" {
  for_each = { for idx, channel in lookup(local.config, "notification_channels", []) : idx => channel }

  display_name = each.value.display_name
  project      = local.config.gcp.project_id
  type         = each.value.type

  labels = lookup(each.value, "labels", {})

  enabled = lookup(each.value, "enabled", true)

  user_labels = local.labels
}
