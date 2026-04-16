output "resource_id" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.this.id
}

output "resource_arn" {
  description = "DynamoDB table ARN"
  value       = aws_dynamodb_table.this.arn
}

output "resource_name" {
  description = "DynamoDB table name"
  value       = local.table_name
}

output "resource_region" {
  description = "DynamoDB table region"
  value       = local.config.meta.region
}

output "table_name" {
  description = "DynamoDB table name"
  value       = aws_dynamodb_table.this.name
}

output "stream_arn" {
  description = "DynamoDB stream ARN"
  value       = aws_dynamodb_table.this.stream_arn
}

output "stream_label" {
  description = "DynamoDB stream label"
  value       = aws_dynamodb_table.this.stream_label
}
