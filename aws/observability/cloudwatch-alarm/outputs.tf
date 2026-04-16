output "resource_id" {
  description = "Resource identifier (first alarm; null if none defined)"
  value       = length(aws_cloudwatch_metric_alarm.this) > 0 ? values(aws_cloudwatch_metric_alarm.this)[0].id : null
}

output "resource_arn" {
  description = "Resource ARN or equivalent (first alarm; null if none defined)"
  value       = length(aws_cloudwatch_metric_alarm.this) > 0 ? values(aws_cloudwatch_metric_alarm.this)[0].arn : null
}

output "alarm_arns" {
  description = "Map of alarm names to ARNs"
  value       = { for k, v in aws_cloudwatch_metric_alarm.this : v.alarm_name => v.arn }
}

output "alarm_ids" {
  description = "Map of alarm names to IDs"
  value       = { for k, v in aws_cloudwatch_metric_alarm.this : v.alarm_name => v.id }
}

output "resource_name" {
  description = "Resource name"
  value       = local.resource_name
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
