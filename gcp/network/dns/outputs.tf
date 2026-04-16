output "resource_id" {
  description = "Resource identifier"
  value       = length(google_dns_managed_zone.this) > 0 ? google_dns_managed_zone.this[0].id : null
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = length(google_dns_managed_zone.this) > 0 ? google_dns_managed_zone.this[0].id : null
}

output "resource_name" {
  description = "Resource name"
  value       = length(google_dns_managed_zone.this) > 0 ? google_dns_managed_zone.this[0].name : null
}

output "zone_name" {
  description = "DNS zone name"
  value       = length(google_dns_managed_zone.this) > 0 ? google_dns_managed_zone.this[0].name : null
}

output "name_servers" {
  description = "DNS zone name servers"
  value       = length(google_dns_managed_zone.this) > 0 ? google_dns_managed_zone.this[0].name_servers : []
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
