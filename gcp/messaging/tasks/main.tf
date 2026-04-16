resource "google_cloud_tasks_queue" "this" {
  name     = local.queue_name
  location = local.config.meta.region
  project  = local.config.gcp.project_id

  rate_limits {
    max_dispatches_per_second = lookup(local.config.queue, "max_dispatches_per_second", 500)
    max_concurrent_dispatches = lookup(local.config.queue, "max_concurrent_dispatches", 1000)
    max_burst_size            = lookup(local.config.queue, "max_burst_size", 100)
  }

  retry_config {
    max_attempts       = lookup(local.config.queue, "max_attempts", 100)
    max_retry_duration = lookup(local.config.queue, "max_retry_duration", "0s")
    max_backoff        = lookup(local.config.queue, "max_backoff", "3600s")
    min_backoff        = lookup(local.config.queue, "min_backoff", "0.1s")
    max_doublings      = lookup(local.config.queue, "max_doublings", 16)
  }

  dynamic "stackdriver_logging_config" {
    for_each = lookup(local.config.queue, "enable_logging", true) ? [1] : []
    content {
      sampling_ratio = lookup(local.config.queue, "log_sampling_ratio", 1.0)
    }
  }
}

resource "google_cloud_tasks_queue_iam_binding" "this" {
  for_each = { for idx, binding in lookup(local.config.queue, "iam_bindings", []) : idx => binding }

  name    = google_cloud_tasks_queue.this.name
  location = google_cloud_tasks_queue.this.location
  project = google_cloud_tasks_queue.this.project
  role    = each.value.role
  members = each.value.members
}
