locals {
  config = yamldecode(file(var.config_file))

  validation = module.validation.validation_passed

  dashboard_name = "${local.config.meta.name}-${local.config.meta.environment}"
}

module "validation" {
  source = "../../../shared/validation"

  config        = local.config
  cloud_provider = "datadog"
  resource_type = "timeboard"
}
