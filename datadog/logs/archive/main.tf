resource "datadog_logs_archive" "this" {
  name  = local.archive_name
  query = local.config.archive.query

  dynamic "s3_archive" {
    for_each = lookup(local.config.archive, "type", "") == "s3" ? [local.config.archive.s3] : []
    content {
      bucket     = s3_archive.value.bucket
      path       = lookup(s3_archive.value, "path", "/")
      account_id = s3_archive.value.account_id
      role_name  = s3_archive.value.role_name
    }
  }

  dynamic "azure_archive" {
    for_each = lookup(local.config.archive, "type", "") == "azure" ? [local.config.archive.azure] : []
    content {
      container       = azure_archive.value.container
      storage_account = azure_archive.value.storage_account
      path            = lookup(azure_archive.value, "path", "/")
      client_id       = azure_archive.value.client_id
      tenant_id       = azure_archive.value.tenant_id
    }
  }

  dynamic "gcs_archive" {
    for_each = lookup(local.config.archive, "type", "") == "gcs" ? [local.config.archive.gcs] : []
    content {
      bucket       = gcs_archive.value.bucket
      path         = lookup(gcs_archive.value, "path", "/")
      client_email = gcs_archive.value.client_email
      project_id   = gcs_archive.value.project_id
    }
  }

  rehydration_tags = lookup(local.config.archive, "rehydration_tags", [])
  include_tags     = lookup(local.config.archive, "include_tags", false)
}
