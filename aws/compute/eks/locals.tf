locals {
  # Decode YAML configuration
  config = yamldecode(file(var.config_file))

  validation = module.validation.validation_passed

  # Generate cluster name
  cluster_name = module.naming.name

  # KMS key ARN for encryption
  kms_key_arn = lookup(lookup(local.config.cluster, "encryption", {}), "kms_key_id", null) != null ? local.config.cluster.encryption.kms_key_id : (length(aws_kms_key.eks) > 0 ? aws_kms_key.eks[0].arn : null)

  # Tags
  tags = module.tagging.tags
}

module "naming" {
  source = "../../../shared/naming"

  environment    = local.config.meta.environment
  team           = local.config.meta.team
  resource_type  = "eks"
  name           = local.config.meta.name
  cloud_provider = "aws"
}

module "tagging" {
  source = "../../../shared/tagging"

  environment = local.config.meta.environment
  team        = local.config.meta.team
  cost_center = local.config.meta.cost_center
  module_path = "aws/compute/eks"
  custom_tags = lookup(local.config, "tags", {})
}

module "validation" {
  source = "../../../shared/validation"

  config         = local.config
  cloud_provider = "aws"
  resource_type  = "eks"
}
