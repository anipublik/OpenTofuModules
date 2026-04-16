resource "aws_cloudtrail" "this" {
  name                          = local.trail_name
  s3_bucket_name                = aws_s3_bucket.this.id
  include_global_service_events = lookup(local.config.trail, "include_global_service_events", true)
  is_multi_region_trail         = lookup(local.config.trail, "multi_region", true)
  enable_log_file_validation    = true

  kms_key_id = local.config.security.encryption_enabled ? local.kms_key_id : null

  dynamic "event_selector" {
    for_each = lookup(local.config.trail, "event_selectors", [])
    content {
      read_write_type           = lookup(event_selector.value, "read_write_type", "All")
      include_management_events = lookup(event_selector.value, "include_management_events", true)

      dynamic "data_resource" {
        for_each = lookup(event_selector.value, "data_resources", [])
        content {
          type   = data_resource.value.type
          values = data_resource.value.values
        }
      }
    }
  }

  dynamic "insight_selector" {
    for_each = lookup(local.config.trail, "insight_types", [])
    content {
      insight_type = insight_selector.value
    }
  }

  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.this.arn}:*"
  cloud_watch_logs_role_arn  = aws_iam_role.cloudwatch.arn

  tags = local.tags

  depends_on = [aws_s3_bucket_policy.this]
}

resource "aws_s3_bucket" "this" {
  bucket = "${local.trail_name}-logs"

  tags = local.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = local.config.security.encryption_enabled ? "aws:kms" : "AES256"
      kms_master_key_id = local.kms_key_id
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.this.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.this.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/cloudtrail/${local.trail_name}"
  retention_in_days = lookup(local.config.trail, "log_retention_days", 90)
  kms_key_id        = local.kms_key_id

  tags = local.tags
}

resource "aws_iam_role" "cloudwatch" {
  name = "${local.trail_name}-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      }
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "${local.trail_name}-cloudwatch-policy"
  role = aws_iam_role.cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.this.arn}:*"
      }
    ]
  })
}
