resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  tags = local.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = local.config.bucket.versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.kms_key_id != null ? "aws:kms" : "AES256"
      kms_master_key_id = local.kms_key_id
    }
    bucket_key_enabled = local.kms_key_id != null ? true : false
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = !local.config.security.public_access
  block_public_policy     = !local.config.security.public_access
  ignore_public_acls      = !local.config.security.public_access
  restrict_public_buckets = !local.config.security.public_access
}

resource "aws_s3_bucket_logging" "this" {
  count = local.config.security.audit_logging ? 1 : 0

  bucket = aws_s3_bucket.this.id

  target_bucket = local.config.bucket.logging_bucket
  target_prefix = "s3-access-logs/${local.bucket_name}/"
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = length(local.config.bucket.lifecycle_rules) > 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = local.config.bucket.lifecycle_rules

    content {
      id     = rule.value.id
      status = rule.value.enabled ? "Enabled" : "Disabled"

      dynamic "transition" {
        for_each = lookup(rule.value, "transitions", [])

        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "noncurrent_version_transition", null) != null ? [rule.value.noncurrent_version_transition] : []

        content {
          noncurrent_days = noncurrent_version_transition.value.days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }

      dynamic "expiration" {
        for_each = lookup(rule.value, "expiration_days", null) != null ? [1] : []

        content {
          days = rule.value.expiration_days
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lookup(rule.value, "noncurrent_version_expiration", null) != null ? [rule.value.noncurrent_version_expiration] : []

        content {
          noncurrent_days = noncurrent_version_expiration.value.days
        }
      }
    }
  }
}

resource "aws_s3_bucket_intelligent_tiering_configuration" "this" {
  count = local.config.bucket.intelligent_tiering ? 1 : 0

  bucket = aws_s3_bucket.this.id
  name   = "EntireBucket"

  tiering {
    access_tier = "ARCHIVE_ACCESS"
    days        = 90
  }

  tiering {
    access_tier = "DEEP_ARCHIVE_ACCESS"
    days        = 180
  }
}
