resource "google_cloud_run_v2_service" "this" {
  name     = local.service_name
  location = local.config.meta.region
  project  = local.config.gcp.project_id

  template {
    scaling {
      min_instance_count = lookup(local.config.service, "min_instances", 0)
      max_instance_count = lookup(local.config.service, "max_instances", 10)
    }

    containers {
      image = local.config.service.image

      dynamic "ports" {
        for_each = lookup(local.config.service, "port", null) != null ? [1] : []
        content {
          container_port = local.config.service.port
        }
      }

      resources {
        limits = {
          cpu    = lookup(local.config.service, "cpu", "1000m")
          memory = lookup(local.config.service, "memory", "512Mi")
        }
      }

      dynamic "env" {
        for_each = lookup(local.config.service, "environment_variables", {})
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = lookup(local.config.service, "secrets", {})
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = env.value.secret
              version = lookup(env.value, "version", "latest")
            }
          }
        }
      }
    }

    dynamic "vpc_access" {
      for_each = lookup(local.config.networking, "vpc_connector", null) != null ? [1] : []
      content {
        connector = local.config.networking.vpc_connector
        egress    = lookup(local.config.networking, "vpc_egress", "PRIVATE_RANGES_ONLY")
      }
    }

    service_account = lookup(local.config.service, "service_account", null)
  }

  traffic {
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
    percent = 100
  }

  labels = local.labels
}

resource "google_cloud_run_service_iam_binding" "public" {
  count = local.config.security.public_access ? 1 : 0

  location = google_cloud_run_v2_service.this.location
  project  = google_cloud_run_v2_service.this.project
  service  = google_cloud_run_v2_service.this.name
  role     = "roles/run.invoker"

  members = ["allUsers"]
}

resource "google_cloud_run_service_iam_binding" "private" {
  for_each = local.config.security.public_access ? {} : { for idx, member in lookup(local.config.service, "invoker_members", []) : idx => member }

  location = google_cloud_run_v2_service.this.location
  project  = google_cloud_run_v2_service.this.project
  service  = google_cloud_run_v2_service.this.name
  role     = "roles/run.invoker"

  members = [each.value]
}
