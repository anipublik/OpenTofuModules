resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = local.frontdoor_name
  resource_group_name = local.config.azure.resource_group
  sku_name            = lookup(local.config.frontdoor, "sku_name", "Standard_AzureFrontDoor")

  tags = local.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  for_each = { for idx, ep in lookup(local.config.frontdoor, "endpoints", []) : idx => ep }

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  tags = local.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  for_each = { for idx, og in lookup(local.config.frontdoor, "origin_groups", []) : idx => og }

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  load_balancing {
    sample_size                        = lookup(each.value.load_balancing, "sample_size", 4)
    successful_samples_required        = lookup(each.value.load_balancing, "successful_samples_required", 3)
    additional_latency_in_milliseconds = lookup(each.value.load_balancing, "additional_latency_ms", 50)
  }

  health_probe {
    protocol            = lookup(each.value.health_probe, "protocol", "Https")
    interval_in_seconds = lookup(each.value.health_probe, "interval_seconds", 30)
    path                = lookup(each.value.health_probe, "path", "/")
    request_type        = lookup(each.value.health_probe, "request_type", "GET")
  }
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  for_each = { for idx, origin in lookup(local.config.frontdoor, "origins", []) : idx => origin }

  name                           = each.value.name
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.this[each.value.origin_group_index].id
  host_name                      = each.value.host_name
  http_port                      = lookup(each.value, "http_port", 80)
  https_port                     = lookup(each.value, "https_port", 443)
  origin_host_header             = lookup(each.value, "origin_host_header", each.value.host_name)
  priority                       = lookup(each.value, "priority", 1)
  weight                         = lookup(each.value, "weight", 1000)
  enabled                        = lookup(each.value, "enabled", true)
  certificate_name_check_enabled = lookup(each.value, "certificate_name_check_enabled", true)
}

resource "azurerm_cdn_frontdoor_route" "this" {
  for_each = { for idx, route in lookup(local.config.frontdoor, "routes", []) : idx => route }

  name                          = each.value.name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this[each.value.endpoint_index].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this[each.value.origin_group_index].id
  cdn_frontdoor_origin_ids      = [for idx in each.value.origin_indices : azurerm_cdn_frontdoor_origin.this[idx].id]

  supported_protocols    = lookup(each.value, "supported_protocols", ["Http", "Https"])
  patterns_to_match      = lookup(each.value, "patterns_to_match", ["/*"])
  forwarding_protocol    = lookup(each.value, "forwarding_protocol", "HttpsOnly")
  https_redirect_enabled = lookup(each.value, "https_redirect_enabled", true)
  enabled                = lookup(each.value, "enabled", true)
}

resource "azurerm_cdn_frontdoor_firewall_policy" "this" {
  count = lookup(local.config.frontdoor, "enable_waf", true) ? 1 : 0

  name                = "${replace(local.frontdoor_name, "-", "")}waf"
  resource_group_name = local.config.azure.resource_group
  sku_name            = azurerm_cdn_frontdoor_profile.this.sku_name
  enabled             = true
  mode                = lookup(local.config.frontdoor.waf, "mode", "Prevention")

  managed_rule {
    type    = "Microsoft_DefaultRuleSet"
    version = "2.1"
    action  = "Block"
  }

  managed_rule {
    type    = "Microsoft_BotManagerRuleSet"
    version = "1.0"
    action  = "Block"
  }

  tags = local.tags
}

resource "azurerm_cdn_frontdoor_security_policy" "this" {
  count = lookup(local.config.frontdoor, "enable_waf", true) ? 1 : 0

  name                     = "${local.frontdoor_name}-security"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.this[0].id

      association {
        patterns_to_match = ["/*"]
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.this[0].id
        }
      }
    }
  }
}
