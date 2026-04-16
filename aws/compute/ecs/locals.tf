locals {
  config = yamldecode(file(var.config_file))

  validation = module.validation.validation_passed

  cluster_name = "${module.naming.name}-cluster"
  service_name = module.naming.name
  kms_key_id   = lookup(lookup(local.config, "encryption", {}), "kms_key_id", null) != null ? local.config.encryption.kms_key_id : (length(aws_kms_key.this) > 0 ? aws_kms_key.this[0].arn : null)

  tags = module.tagging.tags
}

module "naming" {
  source = "../../../shared/naming"

  environment    = local.config.meta.environment
  team           = local.config.meta.team
  resource_type  = "ecs"
  name           = local.config.meta.name
  cloud_provider = "aws"
}

module "tagging" {
  source = "../../../shared/tagging"

  environment = local.config.meta.environment
  team        = local.config.meta.team
  cost_center = local.config.meta.cost_center
  module_path = "aws/compute/ecs"
  custom_tags = lookup(local.config, "tags", {})
}

module "validation" {
  source = "../../../shared/validation"

  config         = local.config
  cloud_provider = "aws"
  resource_type  = "ecs"
}
