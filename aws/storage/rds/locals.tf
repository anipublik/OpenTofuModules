locals {
  config = yamldecode(file(var.config_file))

  # Validate configuration using shared validation module
  validation = module.validation.validation_passed

  db_name = module.naming.name
  kms_key_id = lookup(lookup(local.config, "encryption", {}), "kms_key_id", null)
  
  db_port = lookup(local.port_map, local.config.database.engine, 5432)
  port_map = {
    postgres   = 5432
    mysql      = 3306
    mariadb    = 3306
    oracle-ee  = 1521
    oracle-se2 = 1521
    sqlserver-ee = 1433
    sqlserver-se = 1433
    sqlserver-ex = 1433
    sqlserver-web = 1433
  }

  parameter_group_family = lookup(local.family_map, "${local.config.database.engine}-${split(".", local.config.database.engine_version)[0]}", "postgres15")
  family_map = {
    "postgres-15" = "postgres15"
    "postgres-14" = "postgres14"
    "postgres-13" = "postgres13"
    "mysql-8.0"   = "mysql8.0"
    "mysql-5.7"   = "mysql5.7"
    "mariadb-10.6" = "mariadb10.6"
  }

  tags = module.tagging.tags
}

module "naming" {
  source = "../../../shared/naming"

  environment   = local.config.meta.environment
  team          = local.config.meta.team
  resource_type = "rds"
  name          = local.config.meta.name
  cloud_provider = "aws"
}

module "tagging" {
  source = "../../../shared/tagging"

  environment = local.config.meta.environment
  team        = local.config.meta.team
  cost_center = local.config.meta.cost_center
  module_path = "aws/storage/rds"
  custom_tags = lookup(local.config, "tags", {})
}

module "validation" {
  source = "../../../shared/validation"
  
  config        = local.config
  cloud_provider = "aws"
  resource_type = "rds"
}
