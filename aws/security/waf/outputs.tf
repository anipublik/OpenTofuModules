output "resource_id" {
  description = "Resource identifier"
  value       = aws_wafv2_web_acl.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = aws_wafv2_web_acl.this.arn
}

output "resource_name" {
  description = "Resource name"
  value       = aws_wafv2_web_acl.this.name
}

output "web_acl_id" {
  description = "WAF web ACL ID"
  value       = aws_wafv2_web_acl.this.id
}

output "web_acl_arn" {
  description = "WAF web ACL ARN"
  value       = aws_wafv2_web_acl.this.arn
}

output "web_acl_capacity" {
  description = "WAF web ACL capacity"
  value       = aws_wafv2_web_acl.this.capacity
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
