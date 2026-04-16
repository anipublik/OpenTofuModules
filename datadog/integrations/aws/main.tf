resource "datadog_integration_aws" "this" {
  account_id = local.config.integration.account_id
  role_name  = lookup(local.config.integration, "role_name", "DatadogIntegrationRole")

  filter_tags                      = lookup(local.config.integration, "filter_tags", [])
  host_tags                        = lookup(local.config.integration, "host_tags", [])
  account_specific_namespace_rules = lookup(local.config.integration, "namespace_rules", {})
  excluded_regions                 = lookup(local.config.integration, "excluded_regions", [])
}
