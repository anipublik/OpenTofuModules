output "resource_id" {
  description = "Resource identifier"
  value       = aws_cloudwatch_log_group.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = aws_cloudwatch_log_group.this.arn
}

output "resource_name" {
  description = "Resource name"
  value       = aws_cloudwatch_log_group.this.name
}

output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.this.name
}

output "log_group_arn" {
  description = "CloudWatch log group ARN"
  value       = aws_cloudwatch_log_group.this.arn
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
