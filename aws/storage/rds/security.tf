resource "aws_security_group" "this" {
  name_prefix = "${local.db_name}-"
  description = "Security group for RDS instance ${local.db_name}"
  vpc_id      = local.config.networking.vpc_id

  tags = merge(local.tags, {
    Name = "${local.db_name}-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress" {
  for_each = { for idx, cidr in lookup(local.config.networking, "allowed_cidr_blocks", []) : idx => cidr }

  type              = "ingress"
  from_port         = local.db_port
  to_port           = local.db_port
  protocol          = "tcp"
  cidr_blocks       = [each.value]
  security_group_id = aws_security_group.this.id
  description       = "Allow database access from ${each.value}"
}

resource "aws_security_group_rule" "ingress_sg" {
  for_each = { for idx, sg in lookup(local.config.networking, "allowed_security_groups", []) : idx => sg }

  type                     = "ingress"
  from_port                = local.db_port
  to_port                  = local.db_port
  protocol                 = "tcp"
  source_security_group_id = each.value
  security_group_id        = aws_security_group.this.id
  description              = "Allow database access from security group"
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
