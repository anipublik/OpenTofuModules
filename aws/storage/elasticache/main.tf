resource "aws_elasticache_replication_group" "this" {
  replication_group_id          = local.cluster_name
  replication_group_description = "ElastiCache cluster ${local.cluster_name}"

  engine               = local.config.cluster.engine
  engine_version       = local.config.cluster.engine_version
  node_type            = local.config.cluster.node_type
  num_cache_clusters   = lookup(local.config.cluster, "num_cache_clusters", 2)
  parameter_group_name = aws_elasticache_parameter_group.this.name
  port                 = local.port

  subnet_group_name  = aws_elasticache_subnet_group.this.name
  security_group_ids = [aws_security_group.this.id]

  at_rest_encryption_enabled = local.config.security.encryption_enabled
  transit_encryption_enabled = local.config.security.encryption_enabled
  auth_token_enabled         = local.config.security.encryption_enabled && local.config.cluster.engine == "redis"
  # Auth token handling: raw tokens rejected in production. Use Secrets Manager or
  # pass via a secure channel and reference here from data sources.
  auth_token = local.config.security.encryption_enabled && local.config.cluster.engine == "redis" ? (
    lookup(local.config.cluster, "auth_token", null) != null && local.config.meta.environment == "production" ?
    tobool("ERROR: Raw auth_token not allowed in production. Use Secrets Manager or a data source reference.") :
    lookup(local.config.cluster, "auth_token", null)
  ) : null
  kms_key_id = local.config.security.encryption_enabled ? local.kms_key_id : null

  automatic_failover_enabled = lookup(local.config.reliability, "multi_az", true)
  multi_az_enabled           = lookup(local.config.reliability, "multi_az", true)

  snapshot_retention_limit = lookup(local.config.reliability, "backup_retention_days", 7)
  snapshot_window          = lookup(local.config.cluster, "snapshot_window", "03:00-05:00")
  maintenance_window       = lookup(local.config.cluster, "maintenance_window", "mon:05:00-mon:07:00")

  notification_topic_arn = lookup(local.config.cluster, "notification_topic_arn", null)

  auto_minor_version_upgrade = lookup(local.config.cluster, "auto_minor_version_upgrade", true)

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.slow_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }

  log_delivery_configuration {
    destination      = aws_cloudwatch_log_group.engine_log.name
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  tags = local.tags
}

resource "aws_elasticache_subnet_group" "this" {
  name       = "${local.cluster_name}-subnet-group"
  subnet_ids = local.config.networking.subnet_ids

  tags = local.tags
}

resource "aws_elasticache_parameter_group" "this" {
  name   = "${local.cluster_name}-params"
  family = local.parameter_group_family

  dynamic "parameter" {
    for_each = lookup(local.config.cluster, "parameters", {})
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

resource "aws_security_group" "this" {
  name_prefix = "${local.cluster_name}-"
  description = "Security group for ElastiCache cluster ${local.cluster_name}"
  vpc_id      = local.config.networking.vpc_id

  tags = merge(local.tags, {
    Name = "${local.cluster_name}-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress" {
  for_each = { for idx, sg in lookup(local.config.networking, "allowed_security_groups", []) : idx => sg }

  type                     = "ingress"
  from_port                = local.port
  to_port                  = local.port
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.this.id
  description              = "Allow cache access from security group"
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound traffic"
}

resource "aws_cloudwatch_log_group" "slow_log" {
  name              = "/aws/elasticache/${local.cluster_name}/slow-log"
  retention_in_days = 30
  kms_key_id        = local.kms_key_id

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "engine_log" {
  name              = "/aws/elasticache/${local.cluster_name}/engine-log"
  retention_in_days = 30
  kms_key_id        = local.kms_key_id

  tags = local.tags
}
