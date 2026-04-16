resource "google_service_account" "this" {
  for_each = { for idx, sa in lookup(local.config.iam, "service_accounts", []) : idx => sa }

  account_id   = each.value.account_id
  display_name = lookup(each.value, "display_name", each.value.account_id)
  description  = lookup(each.value, "description", "")
  project      = local.config.gcp.project_id
}

resource "google_service_account_key" "this" {
  for_each = { for idx, sa in lookup(local.config.iam, "service_accounts", []) : idx => sa if lookup(sa, "create_key", false) }

  service_account_id = google_service_account.this[each.key].name
  public_key_type    = "TYPE_X509_PEM_FILE"
}

resource "google_project_iam_member" "this" {
  for_each = { for idx, binding in lookup(local.config.iam, "project_iam_bindings", []) : idx => binding }

  project = local.config.gcp.project_id
  role    = each.value.role
  member  = each.value.member
}

resource "google_project_iam_custom_role" "this" {
  for_each = { for idx, role in lookup(local.config.iam, "custom_roles", []) : idx => role }

  role_id     = each.value.role_id
  title       = lookup(each.value, "title", each.value.role_id)
  description = lookup(each.value, "description", "")
  permissions = each.value.permissions
  project     = local.config.gcp.project_id
  stage       = lookup(each.value, "stage", "GA")
}

resource "google_service_account_iam_binding" "this" {
  for_each = { for idx, binding in lookup(local.config.iam, "service_account_iam_bindings", []) : idx => binding }

  service_account_id = google_service_account.this[each.value.service_account_index].name
  role               = each.value.role
  members            = each.value.members
}
