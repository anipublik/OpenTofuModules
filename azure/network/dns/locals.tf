locals {
  config = yamldecode(file(var.config_file))

  validation = module.validation.validation_passed

  resource_name = module.naming.name
  tags          = module.tagging.tags
}

module "naming" {
  source = "../../../shared/naming"

  environment    = local.config.meta.environment
  team           = local.config.meta.team
  resource_type  = "dns"
  name           = local.config.meta.name
  cloud_provider = "azure"
}

module "tagging" {
  source = "../../../shared/tagging"

  environment = local.config.meta.environment
  team        = local.config.meta.team
  cost_center = local.config.meta.cost_center
  module_path = "azure/network/dns"
  custom_tags = lookup(local.config, "tags", {})
}

module "validation" {
  source = "../../../shared/validation"

  config         = local.config
  cloud_provider = "azure"
  resource_type  = "dns"
}
