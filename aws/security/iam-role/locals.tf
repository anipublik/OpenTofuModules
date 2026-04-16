locals {
  config = yamldecode(file(var.config_file))

  validation = module.validation.validation_passed

  role_name = module.naming.name

  assume_role_policy = {
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = local.config.role.principal
      Condition = lookup(local.config.role, "conditions", null)
    }]
  }

  tags = module.tagging.tags
}

module "naming" {
  source = "../../../shared/naming"

  environment    = local.config.meta.environment
  team           = local.config.meta.team
  resource_type  = "iam-role"
  name           = local.config.meta.name
  cloud_provider = "aws"
}

module "tagging" {
  source = "../../../shared/tagging"

  environment = local.config.meta.environment
  team        = local.config.meta.team
  cost_center = local.config.meta.cost_center
  module_path = "aws/security/iam-role"
  custom_tags = lookup(local.config, "tags", {})
}

module "validation" {
  source = "../../../shared/validation"

  config         = local.config
  cloud_provider = "aws"
  resource_type  = "iam-role"
}
