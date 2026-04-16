resource "aws_kms_key" "this" {
  description             = lookup(local.config.key, "description", "KMS key ${local.key_name}")
  deletion_window_in_days = lookup(local.config.key, "deletion_window_days", 30)
  enable_key_rotation     = lookup(local.config.key, "enable_rotation", true)
  multi_region            = lookup(local.config.key, "multi_region", false)

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      }
    ], lookup(local.config.key, "additional_policy_statements", []))
  })

  tags = local.tags
}

resource "aws_kms_alias" "this" {
  name          = "alias/${local.key_name}"
  target_key_id = aws_kms_key.this.key_id
}

resource "aws_kms_grant" "this" {
  for_each = { for idx, grant in lookup(local.config.key, "grants", []) : idx => grant }

  name              = each.value.name
  key_id            = aws_kms_key.this.key_id
  grantee_principal = each.value.grantee_principal
  operations        = each.value.operations

  dynamic "constraints" {
    for_each = lookup(each.value, "constraints", null) != null ? [1] : []
    content {
      encryption_context_equals = lookup(each.value.constraints, "encryption_context_equals", null)
      encryption_context_subset = lookup(each.value.constraints, "encryption_context_subset", null)
    }
  }
}

data "aws_caller_identity" "current" {}
