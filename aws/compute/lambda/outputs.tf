output "resource_id" {
  description = "Lambda function name"
  value       = aws_lambda_function.this.function_name
}

output "resource_arn" {
  description = "Lambda function ARN"
  value       = aws_lambda_function.this.arn
}

output "resource_name" {
  description = "Lambda function name"
  value       = local.function_name
}

output "resource_region" {
  description = "Lambda function region"
  value       = local.config.meta.region
}

output "invoke_arn" {
  description = "Lambda function invoke ARN"
  value       = aws_lambda_function.this.invoke_arn
}

output "role_arn" {
  description = "Lambda IAM role ARN"
  value       = aws_iam_role.this.arn
}

output "security_group_id" {
  description = "Lambda security group ID (if VPC-enabled)"
  value       = length(aws_security_group.this) > 0 ? aws_security_group.this[0].id : null
}
