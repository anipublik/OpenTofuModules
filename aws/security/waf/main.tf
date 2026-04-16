resource "aws_wafv2_web_acl" "this" {
  name  = local.waf_name
  scope = lookup(local.config.waf, "scope", "REGIONAL")

  default_action {
    dynamic "allow" {
      for_each = lookup(local.config.waf, "default_action", "allow") == "allow" ? [1] : []
      content {}
    }
    dynamic "block" {
      for_each = lookup(local.config.waf, "default_action", "allow") == "block" ? [1] : []
      content {}
    }
  }

  dynamic "rule" {
    for_each = lookup(local.config.waf, "managed_rule_groups", [])
    content {
      name     = rule.value.name
      priority = rule.value.priority

      override_action {
        none {}
      }

      statement {
        managed_rule_group_statement {
          vendor_name = rule.value.vendor_name
          name        = rule.value.name

          dynamic "excluded_rule" {
            for_each = lookup(rule.value, "excluded_rules", [])
            content {
              name = excluded_rule.value
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.waf_name}-${rule.value.name}"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = lookup(local.config.waf, "rate_limit_rules", [])
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        block {}
      }

      statement {
        rate_based_statement {
          limit              = rule.value.limit
          aggregate_key_type = lookup(rule.value, "aggregate_key_type", "IP")
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.waf_name}-${rule.value.name}"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = lookup(local.config.waf, "ip_set_rules", [])
    content {
      name     = rule.value.name
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []
          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []
          content {}
        }
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.this[rule.value.ip_set_name].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "${local.waf_name}-${rule.value.name}"
        sampled_requests_enabled   = true
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = local.waf_name
    sampled_requests_enabled   = true
  }

  tags = local.tags
}

resource "aws_wafv2_ip_set" "this" {
  for_each = { for idx, ip_set in lookup(local.config.waf, "ip_sets", []) : ip_set.name => ip_set }

  name               = each.value.name
  scope              = lookup(local.config.waf, "scope", "REGIONAL")
  ip_address_version = lookup(each.value, "ip_address_version", "IPV4")
  addresses          = each.value.addresses

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "waf" {
  count = lookup(local.config.waf, "logging_enabled", true) ? 1 : 0

  name              = "/aws/wafv2/${local.waf_name}"
  retention_in_days = 30

  tags = local.tags
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count = lookup(local.config.waf, "logging_enabled", true) ? 1 : 0

  resource_arn            = aws_wafv2_web_acl.this.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf[0].arn]
}
