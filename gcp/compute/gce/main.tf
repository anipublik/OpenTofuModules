resource "google_compute_instance" "this" {
  name         = local.instance_name
  machine_type = local.config.instance.machine_type
  zone         = local.config.instance.zone
  project      = local.config.gcp.project_id

  boot_disk {
    initialize_params {
      image = lookup(local.config.instance, "image", "debian-cloud/debian-11")
      size  = lookup(local.config.instance, "disk_size_gb", 20)
      type  = lookup(local.config.instance, "disk_type", "pd-standard")
    }

    auto_delete = lookup(local.config.instance, "auto_delete_disk", true)

    dynamic "kms_key_self_link" {
      for_each = local.config.security.encryption_enabled && lookup(local.config.instance, "kms_key_name", null) != null ? [1] : []
      content {
        kms_key_self_link = local.config.instance.kms_key_name
      }
    }
  }

  dynamic "attached_disk" {
    for_each = lookup(local.config.instance, "additional_disks", [])
    content {
      source      = attached_disk.value.source
      device_name = lookup(attached_disk.value, "device_name", null)
      mode        = lookup(attached_disk.value, "mode", "READ_WRITE")
    }
  }

  network_interface {
    network    = local.config.networking.network
    subnetwork = local.config.networking.subnetwork

    dynamic "access_config" {
      for_each = local.config.security.public_access ? [1] : []
      content {
        nat_ip       = lookup(local.config.instance, "nat_ip", null)
        network_tier = lookup(local.config.instance, "network_tier", "PREMIUM")
      }
    }
  }

  service_account {
    email  = lookup(local.config.instance, "service_account_email", null)
    scopes = lookup(local.config.instance, "scopes", ["cloud-platform"])
  }

  shielded_instance_config {
    enable_secure_boot          = lookup(local.config.instance, "enable_secure_boot", true)
    enable_vtpm                 = lookup(local.config.instance, "enable_vtpm", true)
    enable_integrity_monitoring = lookup(local.config.instance, "enable_integrity_monitoring", true)
  }

  metadata = merge(
    {
      enable-oslogin = "TRUE"
    },
    lookup(local.config.instance, "metadata", {})
  )

  metadata_startup_script = lookup(local.config.instance, "startup_script", null)

  tags = lookup(local.config.instance, "network_tags", [])

  labels = local.labels

  allow_stopping_for_update = lookup(local.config.instance, "allow_stopping_for_update", true)

  deletion_protection = local.config.reliability.deletion_protection
}

resource "google_compute_instance_group" "this" {
  count = lookup(local.config.instance, "create_instance_group", false) ? 1 : 0

  name    = "${local.instance_name}-group"
  zone    = local.config.instance.zone
  project = local.config.gcp.project_id

  instances = [google_compute_instance.this.id]

  dynamic "named_port" {
    for_each = lookup(local.config.instance, "named_ports", [])
    content {
      name = named_port.value.name
      port = named_port.value.port
    }
  }
}
