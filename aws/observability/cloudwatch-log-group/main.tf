resource "aws_cloudwatch_log_group" "this" {
  name              = local.log_group_name
  retention_in_days = lookup(local.config.log_group, "retention_days", 30)
  kms_key_id        = local.config.security.encryption_enabled ? local.kms_key_id : null

  tags = local.tags
}

resource "aws_cloudwatch_log_stream" "this" {
  for_each = toset(lookup(local.config.log_group, "log_streams", []))

  name           = each.value
  log_group_name = aws_cloudwatch_log_group.this.name
}

resource "aws_cloudwatch_log_subscription_filter" "this" {
  for_each = { for idx, filter in lookup(local.config.log_group, "subscription_filters", []) : idx => filter }

  name            = each.value.name
  log_group_name  = aws_cloudwatch_log_group.this.name
  filter_pattern  = each.value.filter_pattern
  destination_arn = each.value.destination_arn
  role_arn        = lookup(each.value, "role_arn", null)
}

resource "aws_cloudwatch_log_metric_filter" "this" {
  for_each = { for idx, filter in lookup(local.config.log_group, "metric_filters", []) : idx => filter }

  name           = each.value.name
  log_group_name = aws_cloudwatch_log_group.this.name
  pattern        = each.value.pattern

  metric_transformation {
    name      = each.value.metric_name
    namespace = each.value.metric_namespace
    value     = each.value.metric_value
    default_value = lookup(each.value, "default_value", null)
  }
}
