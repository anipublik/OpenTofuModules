output "resource_id" {
  description = "Resource identifier"
  value       = aws_route53_zone.this.zone_id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = aws_route53_zone.this.arn
}

output "resource_name" {
  description = "Resource name"
  value       = aws_route53_zone.this.name
}

output "zone_id" {
  description = "Route53 zone ID"
  value       = aws_route53_zone.this.zone_id
}

output "zone_arn" {
  description = "Route53 zone ARN"
  value       = aws_route53_zone.this.arn
}

output "name_servers" {
  description = "Route53 zone name servers"
  value       = aws_route53_zone.this.name_servers
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
