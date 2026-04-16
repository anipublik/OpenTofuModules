resource "datadog_integration_slack_channel" "this" {
  for_each = { for idx, channel in local.config.integration.channels : idx => channel }

  account_name = local.config.integration.account_name
  channel_name = each.value.channel_name
  display {
    message  = lookup(each.value, "display_message", true)
    notified = lookup(each.value, "display_notified", true)
    snapshot = lookup(each.value, "display_snapshot", true)
    tags     = lookup(each.value, "display_tags", true)
  }
}
