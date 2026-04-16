output "pipeline_id" {
  description = "Log pipeline ID"
  value       = datadog_logs_custom_pipeline.this.id
}

output "pipeline_name" {
  description = "Log pipeline name"
  value       = datadog_logs_custom_pipeline.this.name
}
