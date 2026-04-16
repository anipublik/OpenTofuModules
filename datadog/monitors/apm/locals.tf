locals {
  config = yamldecode(file(var.config_file))

  validation = module.validation.validation_passed

  monitor_name = "${local.config.meta.name}-${local.config.meta.environment}"

  tags = concat(
    [
      "environment:${local.config.meta.environment}",
      "managed-by:opentofu",
      "team:${local.config.meta.team}",
    ],
    lookup(local.config, "tags", [])
  )
}

module "validation" {
  source = "../../../shared/validation"

  config        = local.config
  cloud_provider = "datadog"
  resource_type = "monitor-apm"
}
