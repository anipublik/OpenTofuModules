resource "google_secret_manager_secret" "this" {
  for_each = { for idx, secret in local.config.secrets : idx => secret }

  secret_id = each.value.name
  project   = local.config.gcp.project_id

  replication {
    auto {
      dynamic "customer_managed_encryption" {
        for_each = local.config.security.encryption_enabled && lookup(each.value, "kms_key_name", null) != null ? [1] : []
        content {
          kms_key_name = each.value.kms_key_name
        }
      }
    }
  }

  labels = merge(local.labels, lookup(each.value, "labels", {}))
}

resource "google_secret_manager_secret_version" "this" {
  for_each = { for idx, secret in local.config.secrets : idx => secret if lookup(secret, "secret_data", null) != null }

  secret      = google_secret_manager_secret.this[each.key].id
  secret_data = each.value.secret_data
}

resource "google_secret_manager_secret_iam_binding" "this" {
  for_each = { for idx, binding in lookup(local.config, "iam_bindings", []) : idx => binding }

  secret_id = google_secret_manager_secret.this[each.value.secret_index].id
  role      = each.value.role
  members   = each.value.members
  project   = local.config.gcp.project_id
}
