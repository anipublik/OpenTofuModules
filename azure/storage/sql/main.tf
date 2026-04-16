# Optional: Retrieve password from Key Vault
data "azurerm_key_vault_secret" "admin_password" {
  count = lookup(local.config.database, "admin_password_secret_id", null) != null ? 1 : 0

  name         = split("/", local.config.database.admin_password_secret_id)[4]
  key_vault_id = join("/", slice(split("/", local.config.database.admin_password_secret_id), 0, 9))
}

resource "azurerm_mssql_server" "this" {
  name                = local.server_name
  resource_group_name = local.config.azure.resource_group_name
  location            = local.config.meta.region
  version             = lookup(local.config.database, "server_version", "12.0")
  administrator_login = local.config.database.administrator_login

  # Password handling: Key Vault reference required for production
  administrator_login_password = (
    lookup(local.config.database, "admin_password_secret_id", null) != null ?
    data.azurerm_key_vault_secret.admin_password[0].value : (
      local.config.meta.environment == "production" ?
      tobool("ERROR: admin_password_secret_id required for production. Raw passwords not allowed.") :
      local.config.database.administrator_login_password
    )
  )

  minimum_tls_version                  = "1.2"
  public_network_access_enabled        = local.config.security.public_access
  outbound_network_restriction_enabled = false

  azuread_administrator {
    login_username = lookup(local.config.database, "azuread_admin_login", null)
    object_id      = lookup(local.config.database, "azuread_admin_object_id", null)
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_mssql_database" "this" {
  name      = local.database_name
  server_id = azurerm_mssql_server.this.id

  sku_name                    = lookup(local.config.database, "sku_name", "S0")
  max_size_gb                 = lookup(local.config.database, "max_size_gb", 250)
  zone_redundant              = lookup(local.config.reliability, "zone_redundant", true)
  read_scale                  = lookup(local.config.database, "read_scale", false)
  auto_pause_delay_in_minutes = lookup(local.config.database, "auto_pause_delay_minutes", null)
  min_capacity                = lookup(local.config.database, "min_capacity", null)

  short_term_retention_policy {
    retention_days           = lookup(local.config.reliability, "backup_retention_days", 7)
    backup_interval_in_hours = 12
  }

  long_term_retention_policy {
    weekly_retention  = lookup(local.config.database, "weekly_retention", "P1W")
    monthly_retention = lookup(local.config.database, "monthly_retention", "P1M")
    yearly_retention  = lookup(local.config.database, "yearly_retention", "P1Y")
    week_of_year      = lookup(local.config.database, "week_of_year", 1)
  }

  threat_detection_policy {
    state                      = "Enabled"
    email_account_admins       = "Enabled"
    email_addresses            = lookup(local.config.database, "threat_detection_emails", [])
    retention_days             = 90
    storage_endpoint           = lookup(local.config.database, "threat_detection_storage_endpoint", null)
    storage_account_access_key = lookup(local.config.database, "threat_detection_storage_key", null)
  }

  tags = local.tags
}

resource "azurerm_mssql_firewall_rule" "this" {
  for_each = { for idx, rule in lookup(local.config.networking, "firewall_rules", []) : idx => rule }

  name             = each.value.name
  server_id        = azurerm_mssql_server.this.id
  start_ip_address = each.value.start_ip
  end_ip_address   = each.value.end_ip
}

resource "azurerm_mssql_virtual_network_rule" "this" {
  for_each = { for idx, subnet in lookup(local.config.networking, "subnet_ids", []) : idx => subnet }

  name      = "vnet-rule-${each.key}"
  server_id = azurerm_mssql_server.this.id
  subnet_id = each.value
}
