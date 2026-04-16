output "resource_id" {
  description = "Resource identifier"
  value       = aws_sns_topic.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = aws_sns_topic.this.arn
}

output "resource_name" {
  description = "Resource name"
  value       = aws_sns_topic.this.name
}

output "topic_arn" {
  description = "SNS topic ARN"
  value       = aws_sns_topic.this.arn
}

output "topic_id" {
  description = "SNS topic ID"
  value       = aws_sns_topic.this.id
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
