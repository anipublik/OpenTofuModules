locals {
  config = yamldecode(file(var.config_file))

  # Validate configuration using shared validation module
  validation = module.validation.validation_passed

  server_name   = "${local.resource_name}-server"
  database_name = lookup(local.config.database, "database_name", "${local.resource_name}-db")
  
  tags = module.tagging.tags
}

module "naming" {
  source = "../../../shared/naming"

  environment   = local.config.meta.environment
  team          = local.config.meta.team
  resource_type = "sql"
  name          = local.config.meta.name
  cloud_provider = "azure"
}

module "tagging" {
  source = "../../../shared/tagging"

  environment = local.config.meta.environment
  team        = local.config.meta.team
  cost_center = local.config.meta.cost_center
  module_path = "azure/storage/sql"
  custom_tags = lookup(local.config, "tags", {})
}

module "validation" {
  source = "../../../shared/validation"
  
  config        = local.config
  cloud_provider = "azure"
  resource_type = "sql"
}
