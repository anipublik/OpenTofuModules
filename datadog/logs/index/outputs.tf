output "index_id" {
  description = "Log index ID"
  value       = datadog_logs_index.this.id
}

output "index_name" {
  description = "Log index name"
  value       = datadog_logs_index.this.name
}
