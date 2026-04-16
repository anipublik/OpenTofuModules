resource "aws_cloudwatch_metric_alarm" "this" {
  alarm_name          = local.alarm_name
  alarm_description   = lookup(local.config.alarm, "description", "CloudWatch alarm ${local.alarm_name}")
  comparison_operator = local.config.alarm.comparison_operator
  evaluation_periods  = local.config.alarm.evaluation_periods
  metric_name         = local.config.alarm.metric_name
  namespace           = local.config.alarm.namespace
  period              = local.config.alarm.period
  statistic           = lookup(local.config.alarm, "statistic", "Average")
  threshold           = local.config.alarm.threshold
  
  datapoints_to_alarm = lookup(local.config.alarm, "datapoints_to_alarm", null)
  treat_missing_data  = lookup(local.config.alarm, "treat_missing_data", "missing")
  
  dimensions = lookup(local.config.alarm, "dimensions", {})
  
  alarm_actions             = lookup(local.config.alarm, "alarm_actions", [])
  ok_actions                = lookup(local.config.alarm, "ok_actions", [])
  insufficient_data_actions = lookup(local.config.alarm, "insufficient_data_actions", [])

  tags = local.tags
}

resource "aws_cloudwatch_composite_alarm" "this" {
  count = lookup(local.config, "composite_alarm", null) != null ? 1 : 0

  alarm_name          = "${local.alarm_name}-composite"
  alarm_description   = lookup(local.config.composite_alarm, "description", "")
  alarm_rule          = local.config.composite_alarm.alarm_rule
  actions_enabled     = lookup(local.config.composite_alarm, "actions_enabled", true)
  
  alarm_actions             = lookup(local.config.composite_alarm, "alarm_actions", [])
  ok_actions                = lookup(local.config.composite_alarm, "ok_actions", [])
  insufficient_data_actions = lookup(local.config.composite_alarm, "insufficient_data_actions", [])

  tags = local.tags
}
