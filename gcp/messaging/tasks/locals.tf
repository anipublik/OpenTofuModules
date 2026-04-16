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
  resource_type  = "tasks"
  name           = local.config.meta.name
  cloud_provider = "gcp"
}

module "tagging" {
  source = "../../../shared/tagging"

  environment = local.config.meta.environment
  team        = local.config.meta.team
  cost_center = local.config.meta.cost_center
  module_path = "gcp/messaging/tasks"
  custom_tags = lookup(local.config, "tags", {})
}

module "validation" {
  source = "../../../shared/validation"

  config         = local.config
  cloud_provider = "gcp"
  resource_type  = "tasks"
}
