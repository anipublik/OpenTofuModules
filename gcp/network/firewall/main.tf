resource "google_compute_firewall" "this" {
  for_each = { for idx, rule in local.config.firewall.rules : idx => rule }

  name    = "${local.firewall_name}-${each.value.name}"
  network = local.config.networking.network
  project = local.config.gcp.project_id

  direction     = lookup(each.value, "direction", "INGRESS")
  priority      = lookup(each.value, "priority", 1000)
  source_ranges = lookup(each.value, "source_ranges", null)
  source_tags   = lookup(each.value, "source_tags", null)
  target_tags   = lookup(each.value, "target_tags", null)

  destination_ranges = lookup(each.value, "destination_ranges", null)

  dynamic "allow" {
    for_each = lookup(each.value, "allow", [])
    content {
      protocol = allow.value.protocol
      ports    = lookup(allow.value, "ports", null)
    }
  }

  dynamic "deny" {
    for_each = lookup(each.value, "deny", [])
    content {
      protocol = deny.value.protocol
      ports    = lookup(deny.value, "ports", null)
    }
  }

  log_config {
    metadata = lookup(each.value, "log_metadata", "INCLUDE_ALL_METADATA")
  }
}
