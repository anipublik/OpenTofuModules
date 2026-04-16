output "resource_id" {
  description = "ElastiCache replication group ID"
  value       = aws_elasticache_replication_group.this.id
}

output "resource_arn" {
  description = "ElastiCache replication group ARN"
  value       = aws_elasticache_replication_group.this.arn
}

output "resource_name" {
  description = "ElastiCache cluster name"
  value       = local.cluster_name
}

output "resource_region" {
  description = "ElastiCache cluster region"
  value       = local.config.meta.region
}

output "primary_endpoint_address" {
  description = "Primary endpoint address"
  value       = aws_elasticache_replication_group.this.primary_endpoint_address
}

output "reader_endpoint_address" {
  description = "Reader endpoint address"
  value       = aws_elasticache_replication_group.this.reader_endpoint_address
}

output "port" {
  description = "Port number"
  value       = local.port
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.this.id
}
