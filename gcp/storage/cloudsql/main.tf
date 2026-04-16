resource "google_sql_database_instance" "this" {
  name             = local.instance_name
  database_version = local.config.database.database_version
  region           = local.config.meta.region
  project          = local.config.gcp.project_id

  deletion_protection = local.config.security.deletion_protection

  settings {
    tier              = local.config.database.tier
    availability_type = lookup(local.config.reliability, "multi_az", true) ? "REGIONAL" : "ZONAL"
    disk_type         = lookup(local.config.database, "disk_type", "PD_SSD")
    disk_size         = lookup(local.config.database, "disk_size", 10)
    disk_autoresize   = lookup(local.config.database, "disk_autoresize", true)

    backup_configuration {
      enabled                        = true
      start_time                     = lookup(local.config.database, "backup_start_time", "03:00")
      point_in_time_recovery_enabled = lookup(local.config.reliability, "point_in_time_recovery", true)
      transaction_log_retention_days = lookup(local.config.reliability, "backup_retention_days", 7)
      backup_retention_settings {
        retained_backups = lookup(local.config.reliability, "backup_retention_days", 7)
      }
    }

    ip_configuration {
      ipv4_enabled    = lookup(local.config.networking, "ipv4_enabled", false)
      private_network = lookup(local.config.networking, "private_network", null)
      require_ssl     = true

      dynamic "authorized_networks" {
        for_each = lookup(local.config.networking, "authorized_networks", [])
        content {
          name  = authorized_networks.value.name
          value = authorized_networks.value.value
        }
      }
    }

    database_flags {
      name  = "cloudsql_iam_authentication"
      value = "on"
    }

    insights_config {
      query_insights_enabled  = true
      query_string_length     = 1024
      record_application_tags = true
      record_client_address   = true
    }

    maintenance_window {
      day          = lookup(local.config.database, "maintenance_day", 7)
      hour         = lookup(local.config.database, "maintenance_hour", 4)
      update_track = "stable"
    }
  }
}

resource "google_sql_database" "this" {
  for_each = toset(lookup(local.config.database, "databases", []))

  name     = each.value
  instance = google_sql_database_instance.this.name
  project  = local.config.gcp.project_id
}

resource "google_sql_user" "this" {
  for_each = { for idx, user in lookup(local.config.database, "users", []) : idx => user }

  name     = each.value.name
  instance = google_sql_database_instance.this.name
  type     = lookup(each.value, "type", "BUILT_IN")
  project  = local.config.gcp.project_id

  # Password handling: Use Secret Manager or Cloud IAM authentication
  # Raw passwords rejected in production
  password = lookup(each.value, "type", "BUILT_IN") == "BUILT_IN" ? (
    lookup(each.value, "password", null) != null && local.config.meta.environment == "production" ?
    tobool("ERROR: Raw passwords not allowed in production. Use type=CLOUD_IAM_USER or Secret Manager reference") :
    lookup(each.value, "password", null)
  ) : null
}
