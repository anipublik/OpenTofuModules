resource "aws_security_group" "this" {
  name_prefix = "${local.sg_name}-"
  description = lookup(local.config.security_group, "description", "Security group ${local.sg_name}")
  vpc_id      = local.config.networking.vpc_id

  tags = merge(local.tags, {
    Name = local.sg_name
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "ingress" {
  for_each = { for idx, rule in lookup(local.config.security_group, "ingress_rules", []) : idx => rule }

  type                     = "ingress"
  from_port                = each.value.from_port
  to_port                  = each.value.to_port
  protocol                 = each.value.protocol
  cidr_blocks              = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks         = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids          = lookup(each.value, "prefix_list_ids", null)
  source_security_group_id = lookup(each.value, "source_security_group_id", null)
  security_group_id        = aws_security_group.this.id
  description              = lookup(each.value, "description", "")
}

resource "aws_security_group_rule" "egress" {
  for_each = { for idx, rule in lookup(local.config.security_group, "egress_rules", []) : idx => rule }

  type                          = "egress"
  from_port                     = each.value.from_port
  to_port                       = each.value.to_port
  protocol                      = each.value.protocol
  cidr_blocks                   = lookup(each.value, "cidr_blocks", null)
  ipv6_cidr_blocks              = lookup(each.value, "ipv6_cidr_blocks", null)
  prefix_list_ids               = lookup(each.value, "prefix_list_ids", null)
  destination_security_group_id = lookup(each.value, "destination_security_group_id", null)
  security_group_id             = aws_security_group.this.id
  description                   = lookup(each.value, "description", "")
}
