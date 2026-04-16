resource "aws_security_group" "this" {
  count = lookup(local.config, "networking", null) != null ? 1 : 0
  
  name_prefix = "${local.function_name}-"
  description = "Security group for Lambda function ${local.function_name}"
  vpc_id      = local.config.networking.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(local.tags, {
    Name = "${local.function_name}-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_kms_key" "this" {
  count = lookup(lookup(local.config, "encryption", {}), "kms_key_id", null) == null ? 1 : 0

  description             = "KMS key for Lambda function ${local.function_name}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(local.tags, {
    Name = "${local.function_name}-kms"
  })
}

resource "aws_kms_alias" "this" {
  count = lookup(lookup(local.config, "encryption", {}), "kms_key_id", null) == null ? 1 : 0

  name          = "alias/${local.function_name}"
  target_key_id = aws_kms_key.this[0].key_id
}
