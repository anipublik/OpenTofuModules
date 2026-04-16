output "resource_id" {
  description = "Resource identifier"
  value       = values(google_compute_firewall.this)[0].id
}

output "resource_arn" {
  description = "Resource ARN or equivalent"
  value       = values(google_compute_firewall.this)[0].id
}

output "firewall_rule_ids" {
  description = "Map of firewall rule names to IDs"
  value       = { for k, v in google_compute_firewall.this : v.name => v.id }
}

output "firewall_rule_self_links" {
  description = "Map of firewall rule names to self links"
  value       = { for k, v in google_compute_firewall.this : v.name => v.self_link }
}

output "resource_name" {
  description = "Resource name"
  value       = local.resource_name
}

output "resource_region" {
  description = "Resource region"
  value       = local.config.meta.region
}
