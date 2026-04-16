resource "aws_route53_zone" "this" {
  name          = local.config.zone.domain_name
  comment       = lookup(local.config.zone, "comment", "Managed by OpenTofu")
  force_destroy = lookup(local.config.zone, "force_destroy", false)

  dynamic "vpc" {
    for_each = lookup(local.config.zone, "vpc_id", null) != null ? [1] : []
    content {
      vpc_id     = local.config.zone.vpc_id
      vpc_region = lookup(local.config.zone, "vpc_region", local.config.meta.region)
    }
  }

  tags = local.tags
}

resource "aws_route53_record" "this" {
  for_each = { for idx, record in lookup(local.config.zone, "records", []) : idx => record }

  zone_id = aws_route53_zone.this.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = lookup(each.value, "ttl", null)
  records = lookup(each.value, "records", null)

  dynamic "alias" {
    for_each = lookup(each.value, "alias", null) != null ? [1] : []
    content {
      name                   = each.value.alias.name
      zone_id                = each.value.alias.zone_id
      evaluate_target_health = lookup(each.value.alias, "evaluate_target_health", false)
    }
  }

  dynamic "weighted_routing_policy" {
    for_each = lookup(each.value, "weighted_routing_policy", null) != null ? [1] : []
    content {
      weight = each.value.weighted_routing_policy.weight
    }
  }

  dynamic "geolocation_routing_policy" {
    for_each = lookup(each.value, "geolocation_routing_policy", null) != null ? [1] : []
    content {
      continent   = lookup(each.value.geolocation_routing_policy, "continent", null)
      country     = lookup(each.value.geolocation_routing_policy, "country", null)
      subdivision = lookup(each.value.geolocation_routing_policy, "subdivision", null)
    }
  }

  set_identifier  = lookup(each.value, "set_identifier", null)
  health_check_id = lookup(each.value, "health_check_id", null)
}

resource "aws_route53_health_check" "this" {
  for_each = { for idx, hc in lookup(local.config.zone, "health_checks", []) : idx => hc }

  type              = each.value.type
  resource_path     = lookup(each.value, "resource_path", null)
  fqdn              = lookup(each.value, "fqdn", null)
  ip_address        = lookup(each.value, "ip_address", null)
  port              = lookup(each.value, "port", null)
  protocol          = lookup(each.value, "protocol", null)
  request_interval  = lookup(each.value, "request_interval", 30)
  failure_threshold = lookup(each.value, "failure_threshold", 3)
  measure_latency   = lookup(each.value, "measure_latency", false)
  enable_sni        = lookup(each.value, "enable_sni", true)

  tags = merge(local.tags, {
    Name = "${local.zone_name}-hc-${each.key}"
  })
}

resource "aws_route53_query_log" "this" {
  count = lookup(local.config.zone, "query_logging_enabled", false) ? 1 : 0

  zone_id                  = aws_route53_zone.this.zone_id
  cloudwatch_log_group_arn = aws_cloudwatch_log_group.query_log[0].arn
}

resource "aws_cloudwatch_log_group" "query_log" {
  count = lookup(local.config.zone, "query_logging_enabled", false) ? 1 : 0

  name              = "/aws/route53/${local.zone_name}"
  retention_in_days = 30

  tags = local.tags
}
