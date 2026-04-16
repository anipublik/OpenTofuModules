locals {
  # Decode YAML configuration
  config = yamldecode(file(var.config_file))

  # Validate configuration using shared validation module
  validation = module.validation.validation_passed

  # Import shared modules
  resource_name = module.naming.name
  tags          = module.tagging.tags
}

# Naming module
module "naming" {
  source = "../../../shared/naming"

  environment    = local.config.meta.environment
  team           = local.config.meta.team
  resource_type  = "RESOURCE_TYPE" # Replace with actual resource type
  name           = local.config.meta.name
  cloud_provider = "PROVIDER" # Replace with: aws, azure, gcp, or datadog
}

# Tagging module
module "tagging" {
  source = "../../../shared/tagging"

  environment = local.config.meta.environment
  team        = local.config.meta.team
  cost_center = local.config.meta.cost_center
  module_path = "PROVIDER/CATEGORY/MODULE" # Replace with actual module path
  custom_tags = lookup(local.config, "tags", {})
}

module "validation" {
  source = "../../../shared/validation"

  config         = local.config
  cloud_provider = "PROVIDER"      # Replace with: aws, azure, gcp, or datadog
  resource_type  = "RESOURCE_TYPE" # Replace with actual resource type
}
