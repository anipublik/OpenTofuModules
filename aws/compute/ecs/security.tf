resource "aws_security_group" "this" {
  name_prefix = "${local.service_name}-"
  description = "Security group for ECS service ${local.service_name}"
  vpc_id      = local.config.networking.vpc_id

  tags = merge(local.tags, {
    Name = "${local.service_name}-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress_alb" {
  count = lookup(local.config.service, "load_balancer", null) != null ? 1 : 0

  type                     = "ingress"
  from_port                = local.config.task.container_port
  to_port                  = local.config.task.container_port
  protocol                 = "tcp"
  source_security_group_id = lookup(local.config.service.load_balancer, "security_group_id", null)
  security_group_id        = aws_security_group.this.id
  description              = "Allow traffic from ALB"
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

resource "aws_kms_key" "this" {
  count = lookup(lookup(local.config, "encryption", {}), "kms_key_id", null) == null ? 1 : 0

  description             = "KMS key for ECS service ${local.service_name}"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(local.tags, {
    Name = "${local.service_name}-kms"
  })
}

resource "aws_kms_alias" "this" {
  count = lookup(lookup(local.config, "encryption", {}), "kms_key_id", null) == null ? 1 : 0

  name          = "alias/${local.service_name}"
  target_key_id = aws_kms_key.this[0].key_id
}
