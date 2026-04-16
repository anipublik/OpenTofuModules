resource "google_kms_key_ring" "this" {
  name     = local.keyring_name
  location = local.config.meta.region
  project  = local.config.gcp.project_id
}

resource "google_kms_crypto_key" "this" {
  for_each = { for idx, key in local.config.keys : idx => key }

  name            = each.value.name
  key_ring        = google_kms_key_ring.this.id
  rotation_period = lookup(each.value, "rotation_period", "7776000s") # 90 days

  version_template {
    algorithm        = lookup(each.value, "algorithm", "GOOGLE_SYMMETRIC_ENCRYPTION")
    protection_level = lookup(each.value, "protection_level", "SOFTWARE")
  }

  purpose = lookup(each.value, "purpose", "ENCRYPT_DECRYPT")

  lifecycle {
    prevent_destroy = lookup(each.value, "prevent_destroy", true)
  }

  labels = local.labels
}

resource "google_kms_crypto_key_iam_binding" "this" {
  for_each = { for idx, binding in lookup(local.config, "iam_bindings", []) : idx => binding }

  crypto_key_id = google_kms_crypto_key.this[each.value.key_index].id
  role          = each.value.role
  members       = each.value.members
}
