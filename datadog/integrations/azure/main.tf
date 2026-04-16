resource "datadog_integration_azure" "this" {
  tenant_name = local.config.integration.tenant_name
  client_id   = local.config.integration.client_id

  # Client secret handling: Use environment variable DD_AZURE_CLIENT_SECRET
  # Raw secrets in YAML rejected for production
  client_secret = (
    local.config.meta.environment == "production" && lookup(local.config.integration, "client_secret", "") != "" ?
    tobool("ERROR: client_secret not allowed in production YAML. Use environment variable DD_AZURE_CLIENT_SECRET") :
    lookup(local.config.integration, "client_secret", "")
  )

  host_filters = lookup(local.config.integration, "host_filters", "")
}
