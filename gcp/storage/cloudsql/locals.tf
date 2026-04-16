locals {
  config = yamldecode(file(var.config_file))

  # Validate configuration using shared validation module
  validation = module.validation.validation_passed

  resource_name = module.naming.name
  instance_name = local.resource_name
  
  tags = module.tagging.tags
}

module "naming" {
  source = "../../../shared/naming"

  environment   = local.config.meta.environment
  team          = local.config.meta.team
  resource_type = "sql"
  name          = local.config.meta.name
  cloud_provider = "gcp"
}

module "tagging" {
  source = "../../../shared/tagging"

  environment = local.config.meta.environment
  team        = local.config.meta.team
  cost_center = local.config.meta.cost_center
  module_path = "gcp/storage/cloudsql"
  custom_tags = lookup(local.config, "tags", {})
}

module "validation" {
  source = "../../../shared/validation"
  
  config        = local.config
  cloud_provider = "gcp"
  resource_type = "cloudsql"
}
