resource "google_dns_managed_zone" "this" {
  count = lookup(local.config.dns, "create_zone", true) ? 1 : 0

  name        = local.dns_name
  dns_name    = local.config.dns.dns_name
  description = lookup(local.config.dns, "description", "Managed by OpenTofu")
  project     = local.config.gcp.project_id

  visibility = lookup(local.config.dns, "visibility", "public")

  dynamic "private_visibility_config" {
    for_each = lookup(local.config.dns, "visibility", "public") == "private" ? [1] : []
    content {
      dynamic "networks" {
        for_each = lookup(local.config.dns, "private_networks", [])
        content {
          network_url = networks.value
        }
      }
    }
  }

  dynamic "dnssec_config" {
    for_each = lookup(local.config.dns, "enable_dnssec", true) && lookup(local.config.dns, "visibility", "public") == "public" ? [1] : []
    content {
      state         = "on"
      non_existence = lookup(local.config.dns.dnssec_config, "non_existence", "nsec3")

      dynamic "default_key_specs" {
        for_each = lookup(local.config.dns, "dnssec_config", {})
        content {
          algorithm  = lookup(default_key_specs.value, "algorithm", "rsasha256")
          key_length = lookup(default_key_specs.value, "key_length", 2048)
          key_type   = default_key_specs.value.key_type
        }
      }
    }
  }

  labels = local.labels
}

resource "google_dns_record_set" "this" {
  for_each = { for idx, record in lookup(local.config.dns, "records", []) : idx => record }

  name         = each.value.name
  type         = each.value.type
  ttl          = lookup(each.value, "ttl", 300)
  managed_zone = lookup(local.config.dns, "create_zone", true) ? google_dns_managed_zone.this[0].name : local.config.dns.zone_name
  project      = local.config.gcp.project_id

  rrdatas = each.value.rrdatas
}
