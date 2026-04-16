output "resource_id" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.this.id
}

output "resource_arn" {
  description = "Auto Scaling Group ARN"
  value       = aws_autoscaling_group.this.arn
}

output "resource_name" {
  description = "Instance name"
  value       = local.instance_name
}

output "resource_region" {
  description = "Instance region"
  value       = local.config.meta.region
}

output "launch_template_id" {
  description = "Launch template ID"
  value       = aws_launch_template.this.id
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.this.id
}

output "iam_role_arn" {
  description = "IAM role ARN"
  value       = aws_iam_role.this.arn
}

output "autoscaling_group_name" {
  description = "Auto Scaling Group name"
  value       = aws_autoscaling_group.this.name
}
