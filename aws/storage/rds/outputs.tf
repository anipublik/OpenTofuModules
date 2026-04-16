output "resource_id" {
  description = "RDS instance identifier"
  value       = aws_db_instance.this.id
}

output "resource_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.this.arn
}

output "resource_name" {
  description = "RDS instance name"
  value       = local.db_name
}

output "resource_region" {
  description = "RDS instance region"
  value       = local.config.meta.region
}

output "endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.this.endpoint
}

output "address" {
  description = "RDS instance address"
  value       = aws_db_instance.this.address
}

output "port" {
  description = "RDS instance port"
  value       = aws_db_instance.this.port
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.this.id
}
