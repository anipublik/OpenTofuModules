resource "datadog_synthetics_test" "this" {
  name      = local.test_name
  type      = "api"
  subtype   = lookup(local.config.test, "subtype", "http")
  status    = lookup(local.config.test, "status", "live")
  message   = lookup(local.config.test, "message", "")
  locations = local.config.test.locations

  request_definition {
    method = lookup(local.config.test.request, "method", "GET")
    url    = local.config.test.request.url
    body   = lookup(local.config.test.request, "body", null)
    
    dynamic "header" {
      for_each = lookup(local.config.test.request, "headers", {})
      content {
        name  = header.key
        value = header.value
      }
    }
  }

  assertion {
    type     = "statusCode"
    operator = "is"
    target   = lookup(local.config.test.assertions, "status_code", "200")
  }

  dynamic "assertion" {
    for_each = lookup(local.config.test.assertions, "response_time", null) != null ? [1] : []
    content {
      type     = "responseTime"
      operator = "lessThan"
      target   = local.config.test.assertions.response_time
    }
  }

  dynamic "assertion" {
    for_each = lookup(local.config.test.assertions, "body_contains", [])
    content {
      type     = "body"
      operator = "contains"
      target   = assertion.value
    }
  }

  options_list {
    tick_every         = lookup(local.config.test.options, "tick_every", 300)
    follow_redirects   = lookup(local.config.test.options, "follow_redirects", true)
    min_failure_duration = lookup(local.config.test.options, "min_failure_duration", 0)
    min_location_failed  = lookup(local.config.test.options, "min_location_failed", 1)
    
    retry {
      count    = lookup(local.config.test.options, "retry_count", 0)
      interval = lookup(local.config.test.options, "retry_interval", 300)
    }
  }

  tags = local.tags
}
