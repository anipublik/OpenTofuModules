output "resource_id" {
  description = "Resource identifier"
  value       = aws_cloudfront_distribution.this.id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = aws_cloudfront_distribution.this.arn
}

output "distribution_id" {
  description = "CloudFront distribution ID"
  value       = aws_cloudfront_distribution.this.id
}

output "distribution_arn" {
  description = "CloudFront distribution ARN"
  value       = aws_cloudfront_distribution.this.arn
}

output "distribution_domain_name" {
  description = "CloudFront distribution domain name"
  value       = aws_cloudfront_distribution.this.domain_name
}

output "distribution_hosted_zone_id" {
  description = "CloudFront distribution hosted zone ID"
  value       = aws_cloudfront_distribution.this.hosted_zone_id
}

output "resource_name" {
  description = "Resource name"
  value       = local.resource_name
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
