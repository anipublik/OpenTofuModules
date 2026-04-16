resource "google_cloudfunctions2_function" "this" {
  name     = local.function_name
  location = local.config.meta.region
  project  = local.config.gcp.project_id

  build_config {
    runtime     = local.config.function.runtime
    entry_point = local.config.function.entry_point

    source {
      storage_source {
        bucket = local.config.function.source_bucket
        object = local.config.function.source_object
      }
    }

    environment_variables = lookup(local.config.function, "build_environment_variables", {})
  }

  service_config {
    max_instance_count               = lookup(local.config.function, "max_instances", 100)
    min_instance_count               = lookup(local.config.function, "min_instances", 0)
    available_memory                 = lookup(local.config.function, "memory", "256M")
    timeout_seconds                  = lookup(local.config.function, "timeout", 60)
    max_instance_request_concurrency = lookup(local.config.function, "max_concurrency", 1)

    environment_variables = lookup(local.config.function, "environment_variables", {})

    dynamic "secret_environment_variables" {
      for_each = lookup(local.config.function, "secret_environment_variables", [])
      content {
        key        = secret_environment_variables.value.key
        project_id = local.config.gcp.project_id
        secret     = secret_environment_variables.value.secret
        version    = lookup(secret_environment_variables.value, "version", "latest")
      }
    }

    ingress_settings               = local.config.security.public_access ? "ALLOW_ALL" : "ALLOW_INTERNAL_ONLY"
    all_traffic_on_latest_revision = lookup(local.config.function, "all_traffic_on_latest", true)
    service_account_email          = lookup(local.config.function, "service_account_email", null)

    dynamic "vpc_connector" {
      for_each = lookup(local.config.networking, "vpc_connector", null) != null ? [1] : []
      content {
        connector = local.config.networking.vpc_connector
      }
    }

    vpc_connector_egress_settings = lookup(local.config.networking, "vpc_egress", "PRIVATE_RANGES_ONLY")
  }

  dynamic "event_trigger" {
    for_each = lookup(local.config.function, "event_trigger", null) != null ? [1] : []
    content {
      trigger_region        = lookup(local.config.function.event_trigger, "region", local.config.meta.region)
      event_type            = local.config.function.event_trigger.event_type
      pubsub_topic          = lookup(local.config.function.event_trigger, "pubsub_topic", null)
      service_account_email = lookup(local.config.function.event_trigger, "service_account_email", null)

      retry_policy = lookup(local.config.function.event_trigger, "retry_policy", "RETRY_POLICY_RETRY")

      dynamic "event_filters" {
        for_each = lookup(local.config.function.event_trigger, "event_filters", [])
        content {
          attribute = event_filters.value.attribute
          value     = event_filters.value.value
          operator  = lookup(event_filters.value, "operator", "match")
        }
      }
    }
  }

  labels = local.labels
}

resource "google_cloudfunctions2_function_iam_binding" "public" {
  count = local.config.security.public_access ? 1 : 0

  project        = google_cloudfunctions2_function.this.project
  location       = google_cloudfunctions2_function.this.location
  cloud_function = google_cloudfunctions2_function.this.name
  role           = "roles/cloudfunctions.invoker"

  members = ["allUsers"]
}

resource "google_cloudfunctions2_function_iam_binding" "private" {
  for_each = local.config.security.public_access ? {} : { for idx, member in lookup(local.config.function, "invoker_members", []) : idx => member }

  project        = google_cloudfunctions2_function.this.project
  location       = google_cloudfunctions2_function.this.location
  cloud_function = google_cloudfunctions2_function.this.name
  role           = "roles/cloudfunctions.invoker"

  members = [each.value]
}
