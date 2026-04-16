output "dashboard_id" {
  description = "Dashboard ID"
  value       = datadog_dashboard.this.id
}

output "dashboard_url" {
  description = "Dashboard URL"
  value       = datadog_dashboard.this.url
}
