output "integration_id" {
  description = "AWS integration ID"
  value       = datadog_integration_aws.this.id
}

output "external_id" {
  description = "AWS external ID for IAM role"
  value       = datadog_integration_aws.this.external_id
}
