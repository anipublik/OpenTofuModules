output "resource_id" {
  description = "Resource identifier"
  value       = aws_cloudtrail.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = aws_cloudtrail.this.arn
}

output "resource_name" {
  description = "Resource name"
  value       = aws_cloudtrail.this.name
}

output "trail_arn" {
  description = "CloudTrail ARN"
  value       = aws_cloudtrail.this.arn
}

output "trail_id" {
  description = "CloudTrail ID"
  value       = aws_cloudtrail.this.id
}

output "home_region" {
  description = "CloudTrail home region"
  value       = aws_cloudtrail.this.home_region
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
