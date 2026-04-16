output "resource_id" {
  description = "Resource identifier"
  value       = aws_iam_policy.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = aws_iam_policy.this.arn
}

output "resource_name" {
  description = "Resource name"
  value       = aws_iam_policy.this.name
}

output "policy_arn" {
  description = "IAM policy ARN"
  value       = aws_iam_policy.this.arn
}

output "policy_id" {
  description = "IAM policy ID"
  value       = aws_iam_policy.this.id
}

output "policy_name" {
  description = "IAM policy name"
  value       = aws_iam_policy.this.name
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
