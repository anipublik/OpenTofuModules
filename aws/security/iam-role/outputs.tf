output "resource_id" {
  description = "Resource identifier"
  value       = aws_iam_role.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = aws_iam_role.this.arn
}

output "resource_name" {
  description = "Resource name"
  value       = aws_iam_role.this.name
}

output "role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.this.arn
}

output "role_id" {
  description = "IAM role ID"
  value       = aws_iam_role.this.id
}

output "role_name" {
  description = "IAM role name"
  value       = aws_iam_role.this.name
}

output "role_unique_id" {
  description = "IAM role unique ID"
  value       = aws_iam_role.this.unique_id
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
