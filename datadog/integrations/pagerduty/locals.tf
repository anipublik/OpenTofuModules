locals {
  config = yamldecode(file(var.config_file))

  validation = module.validation.validation_passed
}

module "validation" {
  source = "../../../shared/validation"

  config         = local.config
  cloud_provider = "datadog"
  resource_type  = "integration-pagerduty"
}
