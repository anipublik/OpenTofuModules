output "resource_id" {
  description = "Resource identifier"
  value       = aws_lb.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = aws_lb.this.arn
}

output "resource_name" {
  description = "Resource name"
  value       = aws_lb.this.name
}

output "nlb_arn" {
  description = "NLB ARN"
  value       = aws_lb.this.arn
}

output "nlb_dns_name" {
  description = "NLB DNS name"
  value       = aws_lb.this.dns_name
}

output "nlb_zone_id" {
  description = "NLB zone ID"
  value       = aws_lb.this.zone_id
}

output "target_group_arns" {
  description = "Map of target group names to ARNs"
  value       = { for k, v in aws_lb_target_group.this : v.name => v.arn }
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
