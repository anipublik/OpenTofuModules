resource "azurerm_storage_account" "this" {
  name                     = local.storage_account_name
  resource_group_name      = local.config.azure.resource_group
  location                 = local.config.meta.region
  account_tier             = lookup(local.config.storage, "account_tier", "Standard")
  account_replication_type = lookup(local.config.storage, "replication_type", "GRS")
  account_kind             = lookup(local.config.storage, "account_kind", "StorageV2")
  access_tier              = lookup(local.config.storage, "access_tier", "Hot")

  enable_https_traffic_only       = true
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = !local.config.security.public_access

  blob_properties {
    versioning_enabled = lookup(local.config.storage, "versioning_enabled", true)

    delete_retention_policy {
      days = lookup(local.config.storage, "soft_delete_retention_days", 7)
    }

    container_delete_retention_policy {
      days = lookup(local.config.storage, "container_soft_delete_retention_days", 7)
    }
  }

  network_rules {
    default_action             = local.config.security.public_access ? "Allow" : "Deny"
    bypass                     = ["AzureServices"]
    ip_rules                   = lookup(local.config.networking, "allowed_ip_ranges", [])
    virtual_network_subnet_ids = lookup(local.config.networking, "subnet_ids", [])
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_storage_container" "this" {
  for_each = { for idx, container in lookup(local.config.storage, "containers", []) : idx => container }

  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = lookup(each.value, "access_type", "private")
}

resource "azurerm_storage_management_policy" "this" {
  count = length(lookup(local.config.storage, "lifecycle_rules", [])) > 0 ? 1 : 0

  storage_account_id = azurerm_storage_account.this.id

  dynamic "rule" {
    for_each = lookup(local.config.storage, "lifecycle_rules", [])
    content {
      name    = rule.value.name
      enabled = lookup(rule.value, "enabled", true)

      filters {
        prefix_match = lookup(rule.value, "prefix_match", [])
        blob_types   = lookup(rule.value, "blob_types", ["blockBlob"])
      }

      actions {
        base_blob {
          tier_to_cool_after_days_since_modification_greater_than    = lookup(rule.value, "tier_to_cool_days", null)
          tier_to_archive_after_days_since_modification_greater_than = lookup(rule.value, "tier_to_archive_days", null)
          delete_after_days_since_modification_greater_than          = lookup(rule.value, "delete_after_days", null)
        }
      }
    }
  }
}
