resource "google_redis_instance" "this" {
  name           = local.redis_name
  project        = local.config.gcp.project_id
  region         = local.config.meta.region
  tier           = lookup(local.config.redis, "tier", "STANDARD_HA")
  memory_size_gb = local.config.redis.memory_size_gb

  redis_version     = lookup(local.config.redis, "redis_version", "REDIS_7_0")
  display_name      = lookup(local.config.redis, "display_name", local.redis_name)
  reserved_ip_range = lookup(local.config.redis, "reserved_ip_range", null)

  authorized_network = local.config.networking.network
  connect_mode       = lookup(local.config.redis, "connect_mode", "PRIVATE_SERVICE_ACCESS")

  auth_enabled            = lookup(local.config.redis, "auth_enabled", true)
  transit_encryption_mode = lookup(local.config.redis, "transit_encryption_mode", "SERVER_AUTHENTICATION")

  replica_count = lookup(local.config.redis, "replica_count", 1)
  read_replicas_mode = lookup(local.config.redis, "read_replicas_mode", "READ_REPLICAS_ENABLED")

  dynamic "maintenance_policy" {
    for_each = lookup(local.config.redis, "maintenance_policy", null) != null ? [1] : []
    content {
      weekly_maintenance_window {
        day = lookup(local.config.redis.maintenance_policy, "day", "SUNDAY")
        start_time {
          hours   = lookup(local.config.redis.maintenance_policy, "start_hour", 0)
          minutes = lookup(local.config.redis.maintenance_policy, "start_minute", 0)
        }
      }
    }
  }

  dynamic "persistence_config" {
    for_each = lookup(local.config.redis, "persistence_enabled", false) ? [1] : []
    content {
      persistence_mode    = lookup(local.config.redis.persistence_config, "mode", "RDB")
      rdb_snapshot_period = lookup(local.config.redis.persistence_config, "snapshot_period", "ONE_HOUR")
    }
  }

  labels = local.labels
}
