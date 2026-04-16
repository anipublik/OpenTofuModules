resource "google_compute_network" "this" {
  name                    = local.vpc_name
  project                 = local.config.gcp.project_id
  auto_create_subnetworks = false
  routing_mode            = lookup(local.config.network, "routing_mode", "REGIONAL")
}

resource "google_compute_subnetwork" "this" {
  for_each = { for idx, subnet in local.config.network.subnets : idx => subnet }

  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
  region        = each.value.region
  network       = google_compute_network.this.id
  project       = local.config.gcp.project_id

  private_ip_google_access = lookup(each.value, "private_google_access", true)

  dynamic "secondary_ip_range" {
    for_each = lookup(each.value, "secondary_ip_ranges", [])
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "allow_internal" {
  name    = "${local.vpc_name}-allow-internal"
  network = google_compute_network.this.name
  project = local.config.gcp.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [for subnet in local.config.network.subnets : subnet.ip_cidr_range]
}

resource "google_compute_firewall" "deny_all_ingress" {
  name     = "${local.vpc_name}-deny-all-ingress"
  network  = google_compute_network.this.name
  project  = local.config.gcp.project_id
  priority = 65534

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_router" "this" {
  name    = "${local.vpc_name}-router"
  region  = local.config.meta.region
  network = google_compute_network.this.id
  project = local.config.gcp.project_id
}

resource "google_compute_router_nat" "this" {
  name                               = "${local.vpc_name}-nat"
  router                             = google_compute_router.this.name
  region                             = google_compute_router.this.region
  project                            = local.config.gcp.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
