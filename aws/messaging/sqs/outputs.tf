output "resource_id" {
  description = "Resource identifier"
  value       = aws_sqs_queue.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = aws_sqs_queue.this.arn
}

output "resource_name" {
  description = "Resource name"
  value       = aws_sqs_queue.this.name
}

output "queue_url" {
  description = "SQS queue URL"
  value       = aws_sqs_queue.this.url
}

output "queue_arn" {
  description = "SQS queue ARN"
  value       = aws_sqs_queue.this.arn
}

output "dlq_url" {
  description = "Dead letter queue URL"
  value       = length(aws_sqs_queue.dlq) > 0 ? aws_sqs_queue.dlq[0].url : null
}

output "dlq_arn" {
  description = "Dead letter queue ARN"
  value       = length(aws_sqs_queue.dlq) > 0 ? aws_sqs_queue.dlq[0].arn : null
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
