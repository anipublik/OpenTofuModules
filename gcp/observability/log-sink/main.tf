resource "google_logging_project_sink" "this" {
  for_each = { for idx, sink in local.config.sinks : idx => sink }

  name        = "${local.sink_name}-${each.value.name}"
  project     = local.config.gcp.project_id
  destination = each.value.destination
  filter      = lookup(each.value, "filter", "")

  unique_writer_identity = lookup(each.value, "unique_writer_identity", true)

  dynamic "bigquery_options" {
    for_each = lookup(each.value, "use_partitioned_tables", false) ? [1] : []
    content {
      use_partitioned_tables = true
    }
  }

  dynamic "exclusions" {
    for_each = lookup(each.value, "exclusions", [])
    content {
      name        = exclusions.value.name
      description = lookup(exclusions.value, "description", "")
      filter      = exclusions.value.filter
      disabled    = lookup(exclusions.value, "disabled", false)
    }
  }
}

resource "google_logging_organization_sink" "this" {
  for_each = { for idx, sink in lookup(local.config, "organization_sinks", []) : idx => sink }

  name            = "${local.sink_name}-${each.value.name}"
  org_id          = local.config.gcp.organization_id
  destination     = each.value.destination
  filter          = lookup(each.value, "filter", "")
  include_children = lookup(each.value, "include_children", true)

  dynamic "bigquery_options" {
    for_each = lookup(each.value, "use_partitioned_tables", false) ? [1] : []
    content {
      use_partitioned_tables = true
    }
  }

  dynamic "exclusions" {
    for_each = lookup(each.value, "exclusions", [])
    content {
      name        = exclusions.value.name
      description = lookup(exclusions.value, "description", "")
      filter      = exclusions.value.filter
      disabled    = lookup(exclusions.value, "disabled", false)
    }
  }
}
