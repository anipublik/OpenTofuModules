resource "google_compute_global_address" "this" {
  count = lookup(local.config.load_balancer, "type", "EXTERNAL") == "EXTERNAL" ? 1 : 0

  name         = "${local.lb_name}-ip"
  project      = local.config.gcp.project_id
  address_type = "EXTERNAL"
  ip_version   = lookup(local.config.load_balancer, "ip_version", "IPV4")
}

resource "google_compute_backend_service" "this" {
  for_each = { for idx, backend in local.config.load_balancer.backends : idx => backend }

  name                  = "${local.lb_name}-backend-${each.value.name}"
  project               = local.config.gcp.project_id
  protocol              = lookup(each.value, "protocol", "HTTP")
  port_name             = lookup(each.value, "port_name", "http")
  timeout_sec           = lookup(each.value, "timeout_sec", 30)
  enable_cdn            = lookup(each.value, "enable_cdn", false)
  health_checks         = [google_compute_health_check.this[each.key].id]
  load_balancing_scheme = lookup(local.config.load_balancer, "type", "EXTERNAL")

  dynamic "backend" {
    for_each = lookup(each.value, "instance_groups", [])
    content {
      group           = backend.value
      balancing_mode  = lookup(each.value, "balancing_mode", "UTILIZATION")
      capacity_scaler = lookup(each.value, "capacity_scaler", 1.0)
    }
  }

  dynamic "cdn_policy" {
    for_each = lookup(each.value, "enable_cdn", false) ? [1] : []
    content {
      cache_mode        = lookup(each.value.cdn_policy, "cache_mode", "CACHE_ALL_STATIC")
      default_ttl       = lookup(each.value.cdn_policy, "default_ttl", 3600)
      max_ttl           = lookup(each.value.cdn_policy, "max_ttl", 86400)
      client_ttl        = lookup(each.value.cdn_policy, "client_ttl", 3600)
      negative_caching  = lookup(each.value.cdn_policy, "negative_caching", true)
      serve_while_stale = lookup(each.value.cdn_policy, "serve_while_stale", 86400)
    }
  }

  security_policy = lookup(local.config.load_balancer, "security_policy", null)

  log_config {
    enable      = lookup(local.config.load_balancer, "enable_logging", true)
    sample_rate = lookup(local.config.load_balancer, "log_sample_rate", 1.0)
  }
}

resource "google_compute_health_check" "this" {
  for_each = { for idx, backend in local.config.load_balancer.backends : idx => backend }

  name    = "${local.lb_name}-health-${each.value.name}"
  project = local.config.gcp.project_id

  check_interval_sec  = lookup(each.value.health_check, "check_interval_sec", 5)
  timeout_sec         = lookup(each.value.health_check, "timeout_sec", 5)
  healthy_threshold   = lookup(each.value.health_check, "healthy_threshold", 2)
  unhealthy_threshold = lookup(each.value.health_check, "unhealthy_threshold", 2)

  dynamic "http_health_check" {
    for_each = lookup(each.value, "protocol", "HTTP") == "HTTP" ? [1] : []
    content {
      port         = lookup(each.value.health_check, "port", 80)
      request_path = lookup(each.value.health_check, "path", "/")
    }
  }

  dynamic "https_health_check" {
    for_each = lookup(each.value, "protocol", "HTTP") == "HTTPS" ? [1] : []
    content {
      port         = lookup(each.value.health_check, "port", 443)
      request_path = lookup(each.value.health_check, "path", "/")
    }
  }

  dynamic "tcp_health_check" {
    for_each = lookup(each.value, "protocol", "HTTP") == "TCP" ? [1] : []
    content {
      port = lookup(each.value.health_check, "port", 80)
    }
  }
}

resource "google_compute_url_map" "this" {
  name            = local.lb_name
  project         = local.config.gcp.project_id
  default_service = google_compute_backend_service.this[0].id

  dynamic "host_rule" {
    for_each = lookup(local.config.load_balancer, "host_rules", [])
    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.value.path_matcher
    }
  }

  dynamic "path_matcher" {
    for_each = lookup(local.config.load_balancer, "path_matchers", [])
    content {
      name            = path_matcher.value.name
      default_service = google_compute_backend_service.this[path_matcher.value.default_backend_index].id

      dynamic "path_rule" {
        for_each = lookup(path_matcher.value, "path_rules", [])
        content {
          paths   = path_rule.value.paths
          service = google_compute_backend_service.this[path_rule.value.backend_index].id
        }
      }
    }
  }
}

resource "google_compute_target_http_proxy" "this" {
  count = lookup(local.config.load_balancer, "enable_http", true) ? 1 : 0

  name    = "${local.lb_name}-http-proxy"
  project = local.config.gcp.project_id
  url_map = google_compute_url_map.this.id
}

resource "google_compute_target_https_proxy" "this" {
  count = lookup(local.config.load_balancer, "enable_https", true) ? 1 : 0

  name             = "${local.lb_name}-https-proxy"
  project          = local.config.gcp.project_id
  url_map          = google_compute_url_map.this.id
  ssl_certificates = lookup(local.config.load_balancer, "ssl_certificates", [])
}

resource "google_compute_global_forwarding_rule" "http" {
  count = lookup(local.config.load_balancer, "enable_http", true) ? 1 : 0

  name                  = "${local.lb_name}-http"
  project               = local.config.gcp.project_id
  ip_address            = google_compute_global_address.this[0].address
  ip_protocol           = "TCP"
  load_balancing_scheme = lookup(local.config.load_balancer, "type", "EXTERNAL")
  port_range            = "80"
  target                = google_compute_target_http_proxy.this[0].id
}

resource "google_compute_global_forwarding_rule" "https" {
  count = lookup(local.config.load_balancer, "enable_https", true) ? 1 : 0

  name                  = "${local.lb_name}-https"
  project               = local.config.gcp.project_id
  ip_address            = google_compute_global_address.this[0].address
  ip_protocol           = "TCP"
  load_balancing_scheme = lookup(local.config.load_balancer, "type", "EXTERNAL")
  port_range            = "443"
  target                = google_compute_target_https_proxy.this[0].id
}
