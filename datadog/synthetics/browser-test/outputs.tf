output "test_id" {
  description = "Synthetic test ID"
  value       = datadog_synthetics_test.this.id
}

output "test_public_id" {
  description = "Synthetic test public ID"
  value       = datadog_synthetics_test.this.public_id
}

output "test_monitor_id" {
  description = "Associated monitor ID"
  value       = datadog_synthetics_test.this.monitor_id
}
