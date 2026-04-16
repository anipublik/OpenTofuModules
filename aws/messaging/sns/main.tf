resource "aws_sns_topic" "this" {
  name                        = local.topic_name
  display_name                = lookup(local.config.topic, "display_name", local.topic_name)
  fifo_topic                  = lookup(local.config.topic, "fifo", false)
  content_based_deduplication = lookup(local.config.topic, "fifo", false) ? lookup(local.config.topic, "content_based_deduplication", false) : null

  kms_master_key_id = local.config.security.encryption_enabled ? local.kms_key_id : null

  delivery_policy = lookup(local.config.topic, "delivery_policy", null) != null ? jsonencode(local.config.topic.delivery_policy) : null

  tags = local.tags
}

resource "aws_sns_topic_policy" "this" {
  count = lookup(local.config.topic, "policy", null) != null ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = jsonencode(local.config.topic.policy)
}

resource "aws_sns_topic_subscription" "this" {
  for_each = { for idx, sub in lookup(local.config.topic, "subscriptions", []) : idx => sub }

  topic_arn = aws_sns_topic.this.arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint

  filter_policy         = lookup(each.value, "filter_policy", null) != null ? jsonencode(each.value.filter_policy) : null
  raw_message_delivery  = lookup(each.value, "raw_message_delivery", false)
  redrive_policy        = lookup(each.value, "redrive_policy", null) != null ? jsonencode(each.value.redrive_policy) : null
  subscription_role_arn = lookup(each.value, "subscription_role_arn", null)
  delivery_policy       = lookup(each.value, "delivery_policy", null) != null ? jsonencode(each.value.delivery_policy) : null
}
