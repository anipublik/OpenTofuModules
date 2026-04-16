resource "datadog_integration_gcp" "this" {
  project_id     = local.config.integration.project_id
  private_key_id = local.config.integration.private_key_id

  # Private key handling: Use environment variable DD_GCP_PRIVATE_KEY
  # Raw keys in YAML rejected for production
  private_key = (
    local.config.meta.environment == "production" && lookup(local.config.integration, "private_key", "") != "" ?
    tobool("ERROR: private_key not allowed in production YAML. Use environment variable DD_GCP_PRIVATE_KEY") :
    lookup(local.config.integration, "private_key", "")
  )

  client_email = local.config.integration.client_email
  client_id    = local.config.integration.client_id

  host_filters = lookup(local.config.integration, "host_filters", "")
  automute     = lookup(local.config.integration, "automute", false)
}
