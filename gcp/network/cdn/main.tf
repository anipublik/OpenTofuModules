resource "google_compute_backend_bucket" "this" {
  for_each = { for idx, bucket in lookup(local.config.cdn, "backend_buckets", []) : idx => bucket }

  name        = "${local.cdn_name}-backend-${each.value.name}"
  project     = local.config.gcp.project_id
  bucket_name = each.value.bucket_name
  enable_cdn  = true

  cdn_policy {
    cache_mode                   = lookup(each.value.cdn_policy, "cache_mode", "CACHE_ALL_STATIC")
    default_ttl                  = lookup(each.value.cdn_policy, "default_ttl", 3600)
    max_ttl                      = lookup(each.value.cdn_policy, "max_ttl", 86400)
    client_ttl                   = lookup(each.value.cdn_policy, "client_ttl", 3600)
    negative_caching             = lookup(each.value.cdn_policy, "negative_caching", true)
    serve_while_stale            = lookup(each.value.cdn_policy, "serve_while_stale", 86400)

    dynamic "cache_key_policy" {
      for_each = lookup(each.value.cdn_policy, "cache_key_policy", null) != null ? [1] : []
      content {
        include_http_headers   = lookup(each.value.cdn_policy.cache_key_policy, "include_http_headers", null)
        query_string_whitelist = lookup(each.value.cdn_policy.cache_key_policy, "query_string_whitelist", null)
      }
    }

    dynamic "negative_caching_policy" {
      for_each = lookup(each.value.cdn_policy, "negative_caching_policy", [])
      content {
        code = negative_caching_policy.value.code
        ttl  = lookup(negative_caching_policy.value, "ttl", 120)
      }
    }
  }
}

resource "google_compute_url_map" "this" {
  name            = local.cdn_name
  project         = local.config.gcp.project_id
  default_service = google_compute_backend_bucket.this[0].id

  dynamic "host_rule" {
    for_each = lookup(local.config.cdn, "host_rules", [])
    content {
      hosts        = host_rule.value.hosts
      path_matcher = host_rule.value.path_matcher
    }
  }

  dynamic "path_matcher" {
    for_each = lookup(local.config.cdn, "path_matchers", [])
    content {
      name            = path_matcher.value.name
      default_service = google_compute_backend_bucket.this[path_matcher.value.default_backend_index].id

      dynamic "path_rule" {
        for_each = lookup(path_matcher.value, "path_rules", [])
        content {
          paths   = path_rule.value.paths
          service = google_compute_backend_bucket.this[path_rule.value.backend_index].id
        }
      }
    }
  }
}

resource "google_compute_target_http_proxy" "this" {
  count = lookup(local.config.cdn, "enable_http", true) ? 1 : 0

  name    = "${local.cdn_name}-http-proxy"
  project = local.config.gcp.project_id
  url_map = google_compute_url_map.this.id
}

resource "google_compute_target_https_proxy" "this" {
  count = lookup(local.config.cdn, "enable_https", true) ? 1 : 0

  name             = "${local.cdn_name}-https-proxy"
  project          = local.config.gcp.project_id
  url_map          = google_compute_url_map.this.id
  ssl_certificates = lookup(local.config.cdn, "ssl_certificates", [])
}

resource "google_compute_global_address" "this" {
  name         = "${local.cdn_name}-ip"
  project      = local.config.gcp.project_id
  address_type = "EXTERNAL"
  ip_version   = lookup(local.config.cdn, "ip_version", "IPV4")
}

resource "google_compute_global_forwarding_rule" "http" {
  count = lookup(local.config.cdn, "enable_http", true) ? 1 : 0

  name                  = "${local.cdn_name}-http"
  project               = local.config.gcp.project_id
  ip_address            = google_compute_global_address.this.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "80"
  target                = google_compute_target_http_proxy.this[0].id
}

resource "google_compute_global_forwarding_rule" "https" {
  count = lookup(local.config.cdn, "enable_https", true) ? 1 : 0

  name                  = "${local.cdn_name}-https"
  project               = local.config.gcp.project_id
  ip_address            = google_compute_global_address.this.address
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range            = "443"
  target                = google_compute_target_https_proxy.this[0].id
}
