resource "aws_sqs_queue" "this" {
  name                       = local.queue_name
  fifo_queue                 = lookup(local.config.queue, "fifo", false)
  content_based_deduplication = lookup(local.config.queue, "fifo", false) ? lookup(local.config.queue, "content_based_deduplication", false) : null
  
  delay_seconds              = lookup(local.config.queue, "delay_seconds", 0)
  max_message_size           = lookup(local.config.queue, "max_message_size", 262144)
  message_retention_seconds  = lookup(local.config.queue, "message_retention_seconds", 345600)
  receive_wait_time_seconds  = lookup(local.config.queue, "receive_wait_time_seconds", 0)
  visibility_timeout_seconds = lookup(local.config.queue, "visibility_timeout_seconds", 30)

  kms_master_key_id                 = local.config.security.encryption_enabled ? local.kms_key_id : null
  kms_data_key_reuse_period_seconds = local.config.security.encryption_enabled ? 300 : null

  redrive_policy = lookup(local.config.queue, "dead_letter_queue", null) != null ? jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[0].arn
    maxReceiveCount     = lookup(local.config.queue.dead_letter_queue, "max_receive_count", 5)
  }) : null

  tags = local.tags
}

resource "aws_sqs_queue" "dlq" {
  count = lookup(local.config.queue, "dead_letter_queue", null) != null ? 1 : 0

  name                      = "${local.queue_name}-dlq"
  fifo_queue                = lookup(local.config.queue, "fifo", false)
  message_retention_seconds = lookup(local.config.queue.dead_letter_queue, "message_retention_seconds", 1209600)

  kms_master_key_id                 = local.config.security.encryption_enabled ? local.kms_key_id : null
  kms_data_key_reuse_period_seconds = local.config.security.encryption_enabled ? 300 : null

  tags = merge(local.tags, {
    Name = "${local.queue_name}-dlq"
  })
}

resource "aws_sqs_queue_policy" "this" {
  count = lookup(local.config.queue, "policy", null) != null ? 1 : 0

  queue_url = aws_sqs_queue.this.id
  policy    = jsonencode(local.config.queue.policy)
}
