output "resource_id" {
  description = "Resource identifier"
  value       = aws_cloudwatch_event_bus.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = aws_cloudwatch_event_bus.this.arn
}

output "resource_name" {
  description = "Resource name"
  value       = aws_cloudwatch_event_bus.this.name
}

output "event_bus_name" {
  description = "EventBridge event bus name"
  value       = aws_cloudwatch_event_bus.this.name
}

output "event_bus_arn" {
  description = "EventBridge event bus ARN"
  value       = aws_cloudwatch_event_bus.this.arn
}

output "rule_arns" {
  description = "Map of rule names to ARNs"
  value       = { for k, v in aws_cloudwatch_event_rule.this : v.name => v.arn }
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
