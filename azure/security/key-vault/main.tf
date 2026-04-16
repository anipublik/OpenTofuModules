data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                       = local.key_vault_name
  location                   = local.config.meta.region
  resource_group_name        = local.config.azure.resource_group
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = lookup(local.config.key_vault, "sku", "standard")
  soft_delete_retention_days = lookup(local.config.key_vault, "soft_delete_retention_days", 90)
  purge_protection_enabled   = local.config.security.deletion_protection

  enabled_for_deployment          = lookup(local.config.key_vault, "enabled_for_deployment", false)
  enabled_for_disk_encryption     = lookup(local.config.key_vault, "enabled_for_disk_encryption", true)
  enabled_for_template_deployment = lookup(local.config.key_vault, "enabled_for_template_deployment", false)

  enable_rbac_authorization = lookup(local.config.key_vault, "enable_rbac_authorization", true)

  network_acls {
    default_action             = local.config.security.public_access ? "Allow" : "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = lookup(local.config.networking, "allowed_ip_ranges", [])
    virtual_network_subnet_ids = lookup(local.config.networking, "subnet_ids", [])
  }

  tags = local.tags
}

resource "azurerm_key_vault_secret" "this" {
  for_each = { for idx, secret in lookup(local.config.key_vault, "secrets", []) : idx => secret }

  name         = each.value.name
  value        = each.value.value
  key_vault_id = azurerm_key_vault.this.id

  content_type    = lookup(each.value, "content_type", null)
  expiration_date = lookup(each.value, "expiration_date", null)

  tags = local.tags
}

resource "azurerm_key_vault_key" "this" {
  for_each = { for idx, key in lookup(local.config.key_vault, "keys", []) : idx => key }

  name         = each.value.name
  key_vault_id = azurerm_key_vault.this.id
  key_type     = lookup(each.value, "key_type", "RSA")
  key_size     = lookup(each.value, "key_size", 2048)

  key_opts = lookup(each.value, "key_opts", [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey"
  ])

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }

    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }

  tags = local.tags
}
