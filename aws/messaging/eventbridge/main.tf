resource "aws_cloudwatch_event_bus" "this" {
  name = local.bus_name

  tags = local.tags
}

resource "aws_cloudwatch_event_bus_policy" "this" {
  count = lookup(local.config.bus, "policy", null) != null ? 1 : 0

  event_bus_name = aws_cloudwatch_event_bus.this.name
  policy         = jsonencode(local.config.bus.policy)
}

resource "aws_cloudwatch_event_rule" "this" {
  for_each = { for idx, rule in lookup(local.config.bus, "rules", []) : idx => rule }

  name           = each.value.name
  description    = lookup(each.value, "description", "")
  event_bus_name = aws_cloudwatch_event_bus.this.name
  event_pattern  = lookup(each.value, "event_pattern", null) != null ? jsonencode(each.value.event_pattern) : null
  schedule_expression = lookup(each.value, "schedule_expression", null)
  state          = lookup(each.value, "enabled", true) ? "ENABLED" : "DISABLED"

  tags = local.tags
}

resource "aws_cloudwatch_event_target" "this" {
  for_each = merge([
    for rule_idx, rule in lookup(local.config.bus, "rules", []) : {
      for target_idx, target in lookup(rule, "targets", []) : "${rule_idx}-${target_idx}" => {
        rule_name = rule.name
        target    = target
      }
    }
  ]...)

  rule           = each.value.rule_name
  event_bus_name = aws_cloudwatch_event_bus.this.name
  arn            = each.value.target.arn
  role_arn       = lookup(each.value.target, "role_arn", null)
  input          = lookup(each.value.target, "input", null)
  input_path     = lookup(each.value.target, "input_path", null)

  dynamic "retry_policy" {
    for_each = lookup(each.value.target, "retry_policy", null) != null ? [1] : []
    content {
      maximum_event_age       = lookup(each.value.target.retry_policy, "maximum_event_age", 86400)
      maximum_retry_attempts  = lookup(each.value.target.retry_policy, "maximum_retry_attempts", 185)
    }
  }

  dynamic "dead_letter_config" {
    for_each = lookup(each.value.target, "dead_letter_arn", null) != null ? [1] : []
    content {
      arn = each.value.target.dead_letter_arn
    }
  }

  depends_on = [aws_cloudwatch_event_rule.this]
}

resource "aws_cloudwatch_event_archive" "this" {
  for_each = { for idx, archive in lookup(local.config.bus, "archives", []) : idx => archive }

  name             = each.value.name
  event_source_arn = aws_cloudwatch_event_bus.this.arn
  description      = lookup(each.value, "description", "")
  retention_days   = lookup(each.value, "retention_days", 0)
  event_pattern    = lookup(each.value, "event_pattern", null) != null ? jsonencode(each.value.event_pattern) : null
}
