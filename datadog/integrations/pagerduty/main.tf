resource "datadog_integration_pagerduty" "this" {
  dynamic "services" {
    for_each = local.config.integration.services
    content {
      service_name = services.value.service_name
      service_key  = services.value.service_key
    }
  }

  subdomain = lookup(local.config.integration, "subdomain", "")

  # api_token handling: raw secrets rejected for production config.
  # Use environment variable DD_PAGERDUTY_API_TOKEN or a secret store reference.
  api_token = (
    local.config.meta.environment == "production" && lookup(local.config.integration, "api_token", "") != "" ?
    tobool("ERROR: api_token not allowed in production YAML. Use environment variable DD_PAGERDUTY_API_TOKEN or secret reference") :
    lookup(local.config.integration, "api_token", "")
  )
}
