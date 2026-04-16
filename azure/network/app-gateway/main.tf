resource "azurerm_public_ip" "this" {
  name                = "${local.appgw_name}-pip"
  location            = local.config.meta.region
  resource_group_name = local.config.azure.resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = lookup(local.config.app_gateway, "availability_zones", [1, 2, 3])

  tags = local.tags
}

resource "azurerm_application_gateway" "this" {
  name                = local.appgw_name
  location            = local.config.meta.region
  resource_group_name = local.config.azure.resource_group
  zones               = lookup(local.config.app_gateway, "availability_zones", [1, 2, 3])

  sku {
    name     = lookup(local.config.app_gateway.sku, "name", "Standard_v2")
    tier     = lookup(local.config.app_gateway.sku, "tier", "Standard_v2")
    capacity = lookup(local.config.app_gateway.sku, "capacity", 2)
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = local.config.networking.subnet_id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_port {
    name = "https-port"
    port = 443
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.this.id
  }

  backend_address_pool {
    name = "default-backend-pool"
  }

  backend_http_settings {
    name                  = "default-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "default-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "default-backend-pool"
    backend_http_settings_name = "default-http-settings"
    priority                   = 100
  }

  dynamic "ssl_certificate" {
    for_each = lookup(local.config.app_gateway, "ssl_certificates", [])
    content {
      name                = ssl_certificate.value.name
      data                = lookup(ssl_certificate.value, "data", null)
      password            = lookup(ssl_certificate.value, "password", null)
      key_vault_secret_id = lookup(ssl_certificate.value, "key_vault_secret_id", null)
    }
  }

  waf_configuration {
    enabled          = lookup(local.config.app_gateway, "enable_waf", true)
    firewall_mode    = lookup(local.config.app_gateway.waf, "mode", "Prevention")
    rule_set_type    = "OWASP"
    rule_set_version = lookup(local.config.app_gateway.waf, "rule_set_version", "3.2")
  }

  force_firewall_policy_association = lookup(local.config.app_gateway, "force_firewall_policy", true)

  tags = local.tags
}
