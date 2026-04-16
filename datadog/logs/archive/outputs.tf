output "archive_id" {
  description = "Log archive ID"
  value       = datadog_logs_archive.this.id
}

output "archive_name" {
  description = "Log archive name"
  value       = datadog_logs_archive.this.name
}
