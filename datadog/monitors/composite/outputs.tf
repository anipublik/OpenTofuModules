output "monitor_id" {
  description = "Monitor ID"
  value       = datadog_monitor.this.id
}

output "monitor_name" {
  description = "Monitor name"
  value       = datadog_monitor.this.name
}
