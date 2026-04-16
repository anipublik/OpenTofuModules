resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = lookup(local.config.distribution, "ipv6_enabled", true)
  comment             = lookup(local.config.distribution, "comment", "CloudFront distribution ${local.distribution_name}")
  default_root_object = lookup(local.config.distribution, "default_root_object", "index.html")
  price_class         = lookup(local.config.distribution, "price_class", "PriceClass_100")
  web_acl_id          = lookup(local.config.distribution, "waf_acl_id", null)

  aliases = lookup(local.config.distribution, "aliases", [])

  origin {
    domain_name = local.config.distribution.origin.domain_name
    origin_id   = local.config.distribution.origin.origin_id

    dynamic "s3_origin_config" {
      for_each = lookup(local.config.distribution.origin, "s3_origin_config", null) != null ? [1] : []
      content {
        origin_access_identity = aws_cloudfront_origin_access_identity.this[0].cloudfront_access_identity_path
      }
    }

    dynamic "custom_origin_config" {
      for_each = lookup(local.config.distribution.origin, "custom_origin_config", null) != null ? [1] : []
      content {
        http_port              = lookup(local.config.distribution.origin.custom_origin_config, "http_port", 80)
        https_port             = lookup(local.config.distribution.origin.custom_origin_config, "https_port", 443)
        origin_protocol_policy = lookup(local.config.distribution.origin.custom_origin_config, "origin_protocol_policy", "https-only")
        origin_ssl_protocols   = lookup(local.config.distribution.origin.custom_origin_config, "origin_ssl_protocols", ["TLSv1.2"])
      }
    }
  }

  default_cache_behavior {
    allowed_methods  = lookup(local.config.distribution.default_cache_behavior, "allowed_methods", ["GET", "HEAD", "OPTIONS"])
    cached_methods   = lookup(local.config.distribution.default_cache_behavior, "cached_methods", ["GET", "HEAD"])
    target_origin_id = local.config.distribution.origin.origin_id

    forwarded_values {
      query_string = lookup(local.config.distribution.default_cache_behavior, "forward_query_string", false)
      headers      = lookup(local.config.distribution.default_cache_behavior, "forward_headers", [])

      cookies {
        forward = lookup(local.config.distribution.default_cache_behavior, "forward_cookies", "none")
      }
    }

    viewer_protocol_policy = lookup(local.config.distribution.default_cache_behavior, "viewer_protocol_policy", "redirect-to-https")
    min_ttl                = lookup(local.config.distribution.default_cache_behavior, "min_ttl", 0)
    default_ttl            = lookup(local.config.distribution.default_cache_behavior, "default_ttl", 3600)
    max_ttl                = lookup(local.config.distribution.default_cache_behavior, "max_ttl", 86400)
    compress               = lookup(local.config.distribution.default_cache_behavior, "compress", true)
  }

  dynamic "ordered_cache_behavior" {
    for_each = lookup(local.config.distribution, "ordered_cache_behaviors", [])
    content {
      path_pattern     = ordered_cache_behavior.value.path_pattern
      allowed_methods  = lookup(ordered_cache_behavior.value, "allowed_methods", ["GET", "HEAD", "OPTIONS"])
      cached_methods   = lookup(ordered_cache_behavior.value, "cached_methods", ["GET", "HEAD"])
      target_origin_id = local.config.distribution.origin.origin_id

      forwarded_values {
        query_string = lookup(ordered_cache_behavior.value, "forward_query_string", false)
        headers      = lookup(ordered_cache_behavior.value, "forward_headers", [])

        cookies {
          forward = lookup(ordered_cache_behavior.value, "forward_cookies", "none")
        }
      }

      viewer_protocol_policy = lookup(ordered_cache_behavior.value, "viewer_protocol_policy", "redirect-to-https")
      min_ttl                = lookup(ordered_cache_behavior.value, "min_ttl", 0)
      default_ttl            = lookup(ordered_cache_behavior.value, "default_ttl", 3600)
      max_ttl                = lookup(ordered_cache_behavior.value, "max_ttl", 86400)
      compress               = lookup(ordered_cache_behavior.value, "compress", true)
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = lookup(local.config.distribution, "geo_restriction_type", "none")
      locations        = lookup(local.config.distribution, "geo_restriction_locations", [])
    }
  }

  viewer_certificate {
    acm_certificate_arn      = lookup(local.config.distribution, "acm_certificate_arn", null)
    ssl_support_method       = lookup(local.config.distribution, "acm_certificate_arn", null) != null ? "sni-only" : null
    minimum_protocol_version = lookup(local.config.distribution, "minimum_protocol_version", "TLSv1.2_2021")
    cloudfront_default_certificate = lookup(local.config.distribution, "acm_certificate_arn", null) == null ? true : false
  }

  logging_config {
    include_cookies = false
    bucket          = lookup(local.config.distribution, "logging_bucket", "")
    prefix          = lookup(local.config.distribution, "logging_prefix", "cloudfront/")
  }

  tags = local.tags
}

resource "aws_cloudfront_origin_access_identity" "this" {
  count = lookup(local.config.distribution.origin, "s3_origin_config", null) != null ? 1 : 0

  comment = "OAI for ${local.distribution_name}"
}
