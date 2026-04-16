resource "aws_lb" "this" {
  name               = local.alb_name
  internal           = !local.config.security.public_access
  load_balancer_type = "application"
  security_groups    = concat([aws_security_group.this.id], lookup(local.config.networking, "additional_security_groups", []))
  subnets            = local.config.networking.subnet_ids

  enable_deletion_protection       = local.config.security.deletion_protection
  enable_http2                     = lookup(local.config.alb, "enable_http2", true)
  enable_cross_zone_load_balancing = true

  drop_invalid_header_fields = true

  access_logs {
    bucket  = lookup(local.config.alb, "access_logs_bucket", "")
    prefix  = lookup(local.config.alb, "access_logs_prefix", "alb")
    enabled = lookup(local.config.alb, "access_logs_enabled", false)
  }

  tags = local.tags
}

resource "aws_lb_target_group" "this" {
  for_each = { for idx, tg in lookup(local.config.alb, "target_groups", []) : idx => tg }

  name     = "${local.alb_name}-tg-${each.key}"
  port     = each.value.port
  protocol = lookup(each.value, "protocol", "HTTP")
  vpc_id   = local.config.networking.vpc_id

  deregistration_delay = lookup(each.value, "deregistration_delay", 300)

  health_check {
    enabled             = true
    healthy_threshold   = lookup(each.value.health_check, "healthy_threshold", 3)
    unhealthy_threshold = lookup(each.value.health_check, "unhealthy_threshold", 3)
    timeout             = lookup(each.value.health_check, "timeout", 5)
    interval            = lookup(each.value.health_check, "interval", 30)
    path                = lookup(each.value.health_check, "path", "/health")
    matcher             = lookup(each.value.health_check, "matcher", "200")
    protocol            = lookup(each.value.health_check, "protocol", "HTTP")
  }

  stickiness {
    type            = lookup(each.value, "stickiness_type", "lb_cookie")
    cookie_duration = lookup(each.value, "stickiness_duration", 86400)
    enabled         = lookup(each.value, "stickiness_enabled", false)
  }

  tags = merge(local.tags, {
    Name = "${local.alb_name}-tg-${each.key}"
  })
}

resource "aws_lb_listener" "http" {
  count = lookup(local.config.alb, "enable_http_listener", true) ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  count = lookup(local.config.alb, "certificate_arn", null) != null ? 1 : 0

  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = lookup(local.config.alb, "ssl_policy", "ELBSecurityPolicy-TLS-1-2-2017-01")
  certificate_arn   = local.config.alb.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[0].arn
  }
}

resource "aws_lb_listener_rule" "this" {
  for_each = { for idx, rule in lookup(local.config.alb, "listener_rules", []) : idx => rule }

  listener_arn = aws_lb_listener.https[0].arn
  priority     = each.value.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value.target_group_index].arn
  }

  dynamic "condition" {
    for_each = lookup(each.value, "path_patterns", null) != null ? [1] : []
    content {
      path_pattern {
        values = each.value.path_patterns
      }
    }
  }

  dynamic "condition" {
    for_each = lookup(each.value, "host_headers", null) != null ? [1] : []
    content {
      host_header {
        values = each.value.host_headers
      }
    }
  }
}

resource "aws_security_group" "this" {
  name_prefix = "${local.alb_name}-"
  description = "Security group for ALB ${local.alb_name}"
  vpc_id      = local.config.networking.vpc_id

  tags = merge(local.tags, {
    Name = "${local.alb_name}-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = lookup(local.config.networking, "allowed_cidr_blocks", ["0.0.0.0/0"])
  security_group_id = aws_security_group.this.id
  description       = "Allow HTTP"
}

resource "aws_security_group_rule" "https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = lookup(local.config.networking, "allowed_cidr_blocks", ["0.0.0.0/0"])
  security_group_id = aws_security_group.this.id
  description       = "Allow HTTPS"
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound"
}

resource "aws_wafv2_web_acl_association" "this" {
  count = lookup(local.config.alb, "waf_acl_arn", null) != null ? 1 : 0

  resource_arn = aws_lb.this.arn
  web_acl_arn  = local.config.alb.waf_acl_arn
}
