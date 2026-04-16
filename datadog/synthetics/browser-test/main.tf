resource "datadog_synthetics_test" "this" {
  name      = local.test_name
  type      = "browser"
  status    = lookup(local.config.test, "status", "live")
  message   = lookup(local.config.test, "message", "")
  locations = local.config.test.locations

  request_definition {
    method = "GET"
    url    = local.config.test.start_url
  }

  device_ids = lookup(local.config.test, "device_ids", ["laptop_large"])

  dynamic "browser_step" {
    for_each = local.config.test.steps
    content {
      name = browser_step.value.name
      type = browser_step.value.type

      params = jsonencode(lookup(browser_step.value, "params", {}))
    }
  }

  options_list {
    tick_every           = lookup(local.config.test.options, "tick_every", 900)
    min_failure_duration = lookup(local.config.test.options, "min_failure_duration", 0)
    min_location_failed  = lookup(local.config.test.options, "min_location_failed", 1)

    retry {
      count    = lookup(local.config.test.options, "retry_count", 0)
      interval = lookup(local.config.test.options, "retry_interval", 300)
    }
  }

  tags = local.tags
}
