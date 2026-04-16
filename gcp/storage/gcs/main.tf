resource "google_storage_bucket" "this" {
  name          = local.bucket_name
  location      = lookup(local.config.bucket, "location", local.config.meta.region)
  storage_class = lookup(local.config.bucket, "storage_class", "STANDARD")
  project       = local.config.gcp.project_id

  uniform_bucket_level_access = true
  public_access_prevention    = local.config.security.public_access ? "inherited" : "enforced"

  versioning {
    enabled = lookup(local.config.bucket, "versioning", true)
  }

  encryption {
    default_kms_key_name = local.config.security.encryption_enabled ? local.kms_key_name : null
  }

  dynamic "lifecycle_rule" {
    for_each = lookup(local.config.bucket, "lifecycle_rules", [])
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }

      condition {
        age                   = lookup(lifecycle_rule.value.condition, "age", null)
        created_before        = lookup(lifecycle_rule.value.condition, "created_before", null)
        with_state            = lookup(lifecycle_rule.value.condition, "with_state", null)
        matches_storage_class = lookup(lifecycle_rule.value.condition, "matches_storage_class", null)
        num_newer_versions    = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
      }
    }
  }

  dynamic "logging" {
    for_each = lookup(local.config.bucket, "logging_bucket", null) != null ? [1] : []
    content {
      log_bucket        = local.config.bucket.logging_bucket
      log_object_prefix = lookup(local.config.bucket, "logging_prefix", "gcs-logs/")
    }
  }

  labels = local.labels
}

resource "google_storage_bucket_iam_binding" "this" {
  for_each = { for idx, binding in lookup(local.config.bucket, "iam_bindings", []) : idx => binding }

  bucket = google_storage_bucket.this.name
  role   = each.value.role

  members = each.value.members
}
