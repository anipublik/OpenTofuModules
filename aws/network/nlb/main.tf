resource "aws_lb" "this" {
  name               = local.nlb_name
  internal           = !local.config.security.public_access
  load_balancer_type = "network"
  subnets            = local.config.networking.subnet_ids

  enable_deletion_protection       = local.config.security.deletion_protection
  enable_cross_zone_load_balancing = lookup(local.config.nlb, "enable_cross_zone_load_balancing", true)

  access_logs {
    bucket  = lookup(local.config.nlb, "access_logs_bucket", "")
    prefix  = lookup(local.config.nlb, "access_logs_prefix", "nlb")
    enabled = lookup(local.config.nlb, "access_logs_enabled", false)
  }

  tags = local.tags
}

resource "aws_lb_target_group" "this" {
  for_each = { for idx, tg in lookup(local.config.nlb, "target_groups", []) : idx => tg }

  name     = "${local.nlb_name}-tg-${each.key}"
  port     = each.value.port
  protocol = lookup(each.value, "protocol", "TCP")
  vpc_id   = local.config.networking.vpc_id

  deregistration_delay          = lookup(each.value, "deregistration_delay", 300)
  connection_termination        = lookup(each.value, "connection_termination", false)
  preserve_client_ip            = lookup(each.value, "preserve_client_ip", true)
  proxy_protocol_v2             = lookup(each.value, "proxy_protocol_v2", false)

  health_check {
    enabled             = true
    healthy_threshold   = lookup(each.value.health_check, "healthy_threshold", 3)
    unhealthy_threshold = lookup(each.value.health_check, "unhealthy_threshold", 3)
    timeout             = lookup(each.value.health_check, "timeout", 10)
    interval            = lookup(each.value.health_check, "interval", 30)
    port                = lookup(each.value.health_check, "port", "traffic-port")
    protocol            = lookup(each.value.health_check, "protocol", "TCP")
  }

  tags = merge(local.tags, {
    Name = "${local.nlb_name}-tg-${each.key}"
  })
}

resource "aws_lb_listener" "this" {
  for_each = { for idx, listener in lookup(local.config.nlb, "listeners", []) : idx => listener }

  load_balancer_arn = aws_lb.this.arn
  port              = each.value.port
  protocol          = lookup(each.value, "protocol", "TCP")
  certificate_arn   = lookup(each.value, "certificate_arn", null)
  ssl_policy        = lookup(each.value, "ssl_policy", null)
  alpn_policy       = lookup(each.value, "alpn_policy", null)

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.target_group_index].arn
  }

  tags = local.tags
}
