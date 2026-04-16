resource "aws_db_instance" "this" {
  identifier     = local.db_name
  engine         = local.config.database.engine
  engine_version = local.config.database.engine_version
  instance_class = local.config.database.instance_class

  allocated_storage     = local.config.database.allocated_storage
  max_allocated_storage = lookup(local.config.database, "max_allocated_storage", local.config.database.allocated_storage * 2)
  storage_type          = lookup(local.config.database, "storage_type", "gp3")
  storage_encrypted     = local.config.security.encryption_enabled
  kms_key_id            = local.kms_key_id
  iops                  = lookup(local.config.database, "iops", null)

  db_name  = lookup(local.config.database, "db_name", null)
  username = local.config.database.username
  
  # Password handling: AWS-managed secrets by default (recommended)
  # Set manage_master_user_password = false ONLY if using external secret management
  manage_master_user_password   = lookup(local.config.database, "manage_master_user_password", true)
  master_user_secret_kms_key_id = lookup(local.config.database, "manage_master_user_password", true) ? local.kms_key_id : null
  
  # DEPRECATED: Direct password field - will be removed in future version
  # Use manage_master_user_password or reference Secrets Manager ARN instead
  password = lookup(local.config.database, "manage_master_user_password", true) ? null : (
    lookup(local.config.database, "password", null) != null && local.config.meta.environment == "production" ? 
      tobool("ERROR: Raw passwords not allowed in production. Use manage_master_user_password=true or reference Secrets Manager") :
      lookup(local.config.database, "password", null)
  )

  multi_az               = local.config.reliability.multi_az
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  publicly_accessible    = local.config.security.public_access

  backup_retention_period = local.config.reliability.backup_retention_days
  backup_window           = lookup(local.config.database, "backup_window", "03:00-04:00")
  maintenance_window      = lookup(local.config.database, "maintenance_window", "mon:04:00-mon:05:00")

  enabled_cloudwatch_logs_exports = lookup(local.config.database, "enabled_cloudwatch_logs_exports", [])
  performance_insights_enabled    = lookup(local.config.database, "performance_insights_enabled", true)
  performance_insights_kms_key_id = local.kms_key_id

  deletion_protection = local.config.security.deletion_protection
  skip_final_snapshot = false
  # Stable identifier; avoid timestamp() which causes plan drift on every run.
  # Override via database.final_snapshot_identifier if a timestamped name is required.
  final_snapshot_identifier = lookup(local.config.database, "final_snapshot_identifier", "${local.db_name}-final-snapshot")

  copy_tags_to_snapshot = true
  tags                  = local.tags

  lifecycle {
    ignore_changes = [password, final_snapshot_identifier]
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${local.db_name}-subnet-group"
  subnet_ids = local.config.networking.subnet_ids

  tags = merge(local.tags, {
    Name = "${local.db_name}-subnet-group"
  })
}

resource "aws_db_parameter_group" "this" {
  name   = "${local.db_name}-params"
  family = local.parameter_group_family

  dynamic "parameter" {
    for_each = lookup(local.config.database, "parameters", {})
    content {
      name  = parameter.key
      value = parameter.value
    }
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
  }
}
