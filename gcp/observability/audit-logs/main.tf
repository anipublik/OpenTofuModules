resource "google_project_iam_audit_config" "this" {
  for_each = toset(local.config.audit.services)

  project = local.config.gcp.project_id
  service = each.value

  dynamic "audit_log_config" {
    for_each = lookup(local.config.audit, "log_types", ["ADMIN_READ", "DATA_READ", "DATA_WRITE"])
    content {
      log_type         = audit_log_config.value
      exempted_members = lookup(local.config.audit, "exempted_members", [])
    }
  }
}
