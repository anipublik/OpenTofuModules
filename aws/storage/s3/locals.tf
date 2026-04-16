locals {
  # Decode YAML configuration
  config = yamldecode(file(var.config_file))

  validation = module.validation.validation_passed

  # Generate bucket name
  bucket_name = module.naming.name

  # KMS key ID
  kms_key_id = lookup(lookup(local.config, "encryption", {}), "kms_key_id", null)

  # Tags
  tags = module.tagging.tags
}

module "naming" {
  source = "../../../shared/naming"

  environment   = local.config.meta.environment
  team          = local.config.meta.team
  resource_type = "s3"
  name          = local.config.meta.name
  cloud_provider = "aws"
}

module "tagging" {
  source = "../../../shared/tagging"

  environment  = local.config.meta.environment
  team         = local.config.meta.team
  cost_center  = local.config.meta.cost_center
  module_path  = "aws/storage/s3"
  custom_tags  = lookup(local.config, "tags", {})
}

module "validation" {
  source = "../../../shared/validation"

  config        = local.config
  cloud_provider = "aws"
  resource_type = "s3"
}
