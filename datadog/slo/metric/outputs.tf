output "slo_id" {
  description = "SLO ID"
  value       = datadog_service_level_objective.this.id
}

output "slo_name" {
  description = "SLO name"
  value       = datadog_service_level_objective.this.name
}
