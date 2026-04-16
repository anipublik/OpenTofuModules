resource "google_pubsub_topic" "this" {
  name    = local.topic_name
  project = local.config.gcp.project_id

  message_retention_duration = lookup(local.config.topic, "message_retention_duration", "604800s")

  dynamic "message_storage_policy" {
    for_each = lookup(local.config.topic, "allowed_persistence_regions", null) != null ? [1] : []
    content {
      allowed_persistence_regions = local.config.topic.allowed_persistence_regions
    }
  }

  labels = local.labels
}

resource "google_pubsub_topic_iam_binding" "this" {
  for_each = { for idx, binding in lookup(local.config.topic, "iam_bindings", []) : idx => binding }

  project = local.config.gcp.project_id
  topic   = google_pubsub_topic.this.name
  role    = each.value.role
  members = each.value.members
}

resource "google_pubsub_subscription" "this" {
  for_each = { for idx, sub in lookup(local.config.topic, "subscriptions", []) : idx => sub }

  name    = each.value.name
  topic   = google_pubsub_topic.this.name
  project = local.config.gcp.project_id

  ack_deadline_seconds       = lookup(each.value, "ack_deadline_seconds", 10)
  message_retention_duration = lookup(each.value, "message_retention_duration", "604800s")
  retain_acked_messages      = lookup(each.value, "retain_acked_messages", false)
  enable_message_ordering    = lookup(each.value, "enable_message_ordering", false)

  expiration_policy {
    ttl = lookup(each.value, "expiration_ttl", "")
  }

  dynamic "dead_letter_policy" {
    for_each = lookup(each.value, "dead_letter_topic", null) != null ? [1] : []
    content {
      dead_letter_topic     = each.value.dead_letter_topic
      max_delivery_attempts = lookup(each.value, "max_delivery_attempts", 5)
    }
  }

  dynamic "retry_policy" {
    for_each = lookup(each.value, "retry_policy", null) != null ? [1] : []
    content {
      minimum_backoff = lookup(each.value.retry_policy, "minimum_backoff", "10s")
      maximum_backoff = lookup(each.value.retry_policy, "maximum_backoff", "600s")
    }
  }

  labels = local.labels
}
