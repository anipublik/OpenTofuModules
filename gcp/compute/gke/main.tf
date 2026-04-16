resource "google_container_cluster" "this" {
  name     = local.cluster_name
  location = local.config.meta.region

  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = lookup(local.config.cluster, "release_channel", "REGULAR")
  }

  network    = local.config.networking.network
  subnetwork = local.config.networking.subnetwork

  ip_allocation_policy {
    cluster_secondary_range_name  = lookup(local.config.networking, "pods_range_name", "pods")
    services_secondary_range_name = lookup(local.config.networking, "services_range_name", "services")
  }

  private_cluster_config {
    enable_private_nodes    = lookup(local.config.cluster, "enable_private_nodes", true)
    enable_private_endpoint = lookup(local.config.cluster, "enable_private_endpoint", false)
    master_ipv4_cidr_block  = lookup(local.config.cluster, "master_ipv4_cidr_block", "172.16.0.0/28")

    master_global_access_config {
      enabled = lookup(local.config.cluster, "master_global_access", false)
    }
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = lookup(local.config.cluster, "master_authorized_networks", [])
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = lookup(cidr_blocks.value, "display_name", "")
      }
    }
  }

  workload_identity_config {
    workload_pool = "${local.config.gcp.project_id}.svc.id.goog"
  }

  addons_config {
    http_load_balancing {
      disabled = !lookup(local.config.cluster.addons, "http_load_balancing", true)
    }

    horizontal_pod_autoscaling {
      disabled = !lookup(local.config.cluster.addons, "horizontal_pod_autoscaling", true)
    }

    network_policy_config {
      disabled = !lookup(local.config.cluster.addons, "network_policy", true)
    }

    gce_persistent_disk_csi_driver_config {
      enabled = lookup(local.config.cluster.addons, "gce_persistent_disk_csi_driver", true)
    }
  }

  logging_config {
    enable_components = lookup(local.config.cluster.logging, "enable_components", ["SYSTEM_COMPONENTS", "WORKLOADS"])
  }

  monitoring_config {
    enable_components = lookup(local.config.cluster.monitoring, "enable_components", ["SYSTEM_COMPONENTS", "WORKLOADS"])

    managed_prometheus {
      enabled = lookup(local.config.cluster.monitoring, "managed_prometheus", true)
    }
  }

  binary_authorization {
    evaluation_mode = lookup(local.config.cluster, "binary_authorization_mode", "DISABLED")
  }

  database_encryption {
    state    = local.config.security.encryption_enabled ? "ENCRYPTED" : "DECRYPTED"
    key_name = local.config.security.encryption_enabled ? local.kms_key_name : null
  }

  resource_labels = local.labels
}

resource "google_container_node_pool" "this" {
  for_each = { for idx, np in local.config.node_pools : idx => np }

  name       = each.value.name
  location   = local.config.meta.region
  cluster    = google_container_cluster.this.name
  node_count = lookup(each.value, "initial_node_count", 1)

  autoscaling {
    min_node_count = lookup(each.value.autoscaling, "min_node_count", 1)
    max_node_count = lookup(each.value.autoscaling, "max_node_count", 10)
  }

  management {
    auto_repair  = lookup(each.value.management, "auto_repair", true)
    auto_upgrade = lookup(each.value.management, "auto_upgrade", true)
  }

  node_config {
    machine_type = each.value.machine_type
    disk_size_gb = lookup(each.value, "disk_size_gb", 100)
    disk_type    = lookup(each.value, "disk_type", "pd-standard")
    image_type   = lookup(each.value, "image_type", "COS_CONTAINERD")
    preemptible  = lookup(each.value, "preemptible", false)
    spot         = lookup(each.value, "spot", false)

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    service_account = lookup(each.value, "service_account", null)

    shielded_instance_config {
      enable_secure_boot          = lookup(each.value.shielded_instance_config, "enable_secure_boot", true)
      enable_integrity_monitoring = lookup(each.value.shielded_instance_config, "enable_integrity_monitoring", true)
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = lookup(each.value, "labels", {})

    dynamic "taint" {
      for_each = lookup(each.value, "taints", [])
      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }
}
