output "channel_ids" {
  description = "Slack channel integration IDs"
  value       = { for k, v in datadog_integration_slack_channel.this : k => v.id }
}
