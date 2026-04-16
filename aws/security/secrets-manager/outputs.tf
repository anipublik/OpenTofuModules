output "resource_id" {
  description = "Secret ID"
  value       = aws_secretsmanager_secret.this.id
}

output "resource_arn" {
  description = "Secret ARN"
  value       = aws_secretsmanager_secret.this.arn
}

output "resource_name" {
  description = "Secret name"
  value       = local.secret_name
}

output "resource_region" {
  description = "Secret region"
  value       = local.config.meta.region
}

output "secret_arn" {
  description = "Secret ARN"
  value       = aws_secretsmanager_secret.this.arn
}

output "secret_name" {
  description = "Secret name"
  value       = aws_secretsmanager_secret.this.name
}

output "version_id" {
  description = "Secret version ID"
  value       = length(aws_secretsmanager_secret_version.this) > 0 ? aws_secretsmanager_secret_version.this[0].version_id : null
}
