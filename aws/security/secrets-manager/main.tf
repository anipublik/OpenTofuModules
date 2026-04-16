resource "aws_secretsmanager_secret" "this" {
  name                    = local.secret_name
  description             = lookup(local.config.secret, "description", "Secret ${local.secret_name}")
  kms_key_id              = local.kms_key_id
  recovery_window_in_days = lookup(local.config.secret, "recovery_window_days", 30)

  dynamic "replica" {
    for_each = lookup(local.config.secret, "replica_regions", [])
    content {
      region     = replica.value
      kms_key_id = lookup(local.config.secret, "replica_kms_key_ids", {})[replica.value]
    }
  }

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "this" {
  count = lookup(local.config.secret, "secret_string", null) != null ? 1 : 0

  secret_id     = aws_secretsmanager_secret.this.id
  secret_string = local.config.secret.secret_string

  lifecycle {
    ignore_changes = [secret_string]
  }
}

resource "aws_secretsmanager_secret_rotation" "this" {
  count = lookup(local.config.secret, "rotation_enabled", false) ? 1 : 0

  secret_id           = aws_secretsmanager_secret.this.id
  rotation_lambda_arn = local.config.secret.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = lookup(local.config.secret, "rotation_days", 30)
  }
}

resource "aws_secretsmanager_secret_policy" "this" {
  count = lookup(local.config.secret, "resource_policy", null) != null ? 1 : 0

  secret_arn = aws_secretsmanager_secret.this.arn
  policy     = jsonencode(local.config.secret.resource_policy)
}
