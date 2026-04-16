output "resource_id" {
  description = "Resource identifier"
  value       = aws_security_group.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = aws_security_group.this.arn
}

output "resource_name" {
  description = "Resource name"
  value       = aws_security_group.this.name
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.this.id
}

output "security_group_arn" {
  description = "Security group ARN"
  value       = aws_security_group.this.arn
}

output "security_group_name" {
  description = "Security group name"
  value       = aws_security_group.this.name
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
