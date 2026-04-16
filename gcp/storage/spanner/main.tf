resource "google_spanner_instance" "this" {
  name             = local.spanner_name
  project          = local.config.gcp.project_id
  config           = lookup(local.config.spanner, "config", "regional-${local.config.meta.region}")
  display_name     = lookup(local.config.spanner, "display_name", local.spanner_name)
  processing_units = lookup(local.config.spanner, "processing_units", null)
  num_nodes        = lookup(local.config.spanner, "num_nodes", 1)

  labels = local.labels
}

resource "google_spanner_database" "this" {
  for_each = { for idx, db in local.config.spanner.databases : idx => db }

  instance                 = google_spanner_instance.this.name
  name                     = each.value.name
  project                  = local.config.gcp.project_id
  version_retention_period = lookup(each.value, "version_retention_period", "1h")
  ddl                      = lookup(each.value, "ddl", [])

  deletion_protection = lookup(each.value, "deletion_protection", true)

  dynamic "encryption_config" {
    for_each = local.config.security.encryption_enabled && lookup(each.value, "kms_key_name", null) != null ? [1] : []
    content {
      kms_key_name = each.value.kms_key_name
    }
  }
}

resource "google_spanner_database_iam_binding" "this" {
  for_each = { for idx, binding in lookup(local.config.spanner, "iam_bindings", []) : idx => binding }

  instance = google_spanner_instance.this.name
  database = google_spanner_database.this[each.value.database_index].name
  project  = local.config.gcp.project_id
  role     = each.value.role
  members  = each.value.members
}
