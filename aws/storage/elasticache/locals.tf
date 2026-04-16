locals {
  config = yamldecode(file(var.config_file))

  validation = module.validation.validation_passed

  cluster_name = module.naming.name
  kms_key_id = lookup(lookup(local.config, "encryption", {}), "kms_key_id", null)
  
  port = local.config.cluster.engine == "redis" ? 6379 : 11211
  
  parameter_group_family = lookup(local.family_map, "${local.config.cluster.engine}-${split(".", local.config.cluster.engine_version)[0]}", "redis7")
  family_map = {
    "redis-7" = "redis7"
    "redis-6" = "redis6.x"
    "memcached-1.6" = "memcached1.6"
  }
  
  tags = module.tagging.tags
}

module "naming" {
  source = "../../../shared/naming"

  environment   = local.config.meta.environment
  team          = local.config.meta.team
  resource_type = "elasticache"
  name          = local.config.meta.name
  cloud_provider = "aws"
}

module "tagging" {
  source = "../../../shared/tagging"

  environment = local.config.meta.environment
  team        = local.config.meta.team
  cost_center = local.config.meta.cost_center
  module_path = "aws/storage/elasticache"
  custom_tags = lookup(local.config, "tags", {})
}

module "validation" {
  source = "../../../shared/validation"

  config        = local.config
  cloud_provider = "aws"
  resource_type = "elasticache"
}
