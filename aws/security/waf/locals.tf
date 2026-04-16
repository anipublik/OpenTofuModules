locals {
  config = yamldecode(file(var.config_file))

  validation = module.validation.validation_passed

  resource_name = module.naming.name
  tags = module.tagging.tags
}

module "naming" {
  source = "../../../shared/naming"

  environment   = local.config.meta.environment
  team          = local.config.meta.team
  resource_type = "waf"
  name          = local.config.meta.name
  cloud_provider = "aws"
}

module "tagging" {
  source = "../../../shared/tagging"

  environment = local.config.meta.environment
  team        = local.config.meta.team
  cost_center = local.config.meta.cost_center
  module_path = "aws/security/waf"
  custom_tags = lookup(local.config, "tags", {})
}

module "validation" {
  source = "../../../shared/validation"

  config        = local.config
  cloud_provider = "aws"
  resource_type = "waf"
}
