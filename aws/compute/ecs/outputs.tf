output "resource_id" {
  description = "ECS cluster ID"
  value       = aws_ecs_cluster.this.id
}

output "resource_arn" {
  description = "ECS cluster ARN"
  value       = aws_ecs_cluster.this.arn
}

output "resource_name" {
  description = "ECS service name"
  value       = local.service_name
}

output "resource_region" {
  description = "ECS cluster region"
  value       = local.config.meta.region
}

output "cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.this.name
}

output "service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.this.name
}

output "task_definition_arn" {
  description = "Task definition ARN"
  value       = aws_ecs_task_definition.this.arn
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.this.id
}

output "execution_role_arn" {
  description = "Execution role ARN"
  value       = aws_iam_role.execution.arn
}

output "task_role_arn" {
  description = "Task role ARN"
  value       = aws_iam_role.task.arn
}
