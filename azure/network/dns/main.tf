resource "azurerm_dns_zone" "this" {
  count = lookup(local.config.dns, "create_zone", true) ? 1 : 0

  name                = local.config.dns.zone_name
  resource_group_name = local.config.azure.resource_group

  tags = local.tags
}

resource "azurerm_dns_a_record" "this" {
  for_each = { for idx, record in lookup(local.config.dns, "a_records", []) : idx => record }

  name                = each.value.name
  zone_name           = lookup(local.config.dns, "create_zone", true) ? azurerm_dns_zone.this[0].name : local.config.dns.zone_name
  resource_group_name = local.config.azure.resource_group
  ttl                 = lookup(each.value, "ttl", 300)
  records             = each.value.records

  tags = local.tags
}

resource "azurerm_dns_aaaa_record" "this" {
  for_each = { for idx, record in lookup(local.config.dns, "aaaa_records", []) : idx => record }

  name                = each.value.name
  zone_name           = lookup(local.config.dns, "create_zone", true) ? azurerm_dns_zone.this[0].name : local.config.dns.zone_name
  resource_group_name = local.config.azure.resource_group
  ttl                 = lookup(each.value, "ttl", 300)
  records             = each.value.records

  tags = local.tags
}

resource "azurerm_dns_cname_record" "this" {
  for_each = { for idx, record in lookup(local.config.dns, "cname_records", []) : idx => record }

  name                = each.value.name
  zone_name           = lookup(local.config.dns, "create_zone", true) ? azurerm_dns_zone.this[0].name : local.config.dns.zone_name
  resource_group_name = local.config.azure.resource_group
  ttl                 = lookup(each.value, "ttl", 300)
  record              = each.value.record

  tags = local.tags
}

resource "azurerm_dns_mx_record" "this" {
  for_each = { for idx, record in lookup(local.config.dns, "mx_records", []) : idx => record }

  name                = each.value.name
  zone_name           = lookup(local.config.dns, "create_zone", true) ? azurerm_dns_zone.this[0].name : local.config.dns.zone_name
  resource_group_name = local.config.azure.resource_group
  ttl                 = lookup(each.value, "ttl", 300)

  dynamic "record" {
    for_each = each.value.records
    content {
      preference = record.value.preference
      exchange   = record.value.exchange
    }
  }

  tags = local.tags
}

resource "azurerm_dns_txt_record" "this" {
  for_each = { for idx, record in lookup(local.config.dns, "txt_records", []) : idx => record }

  name                = each.value.name
  zone_name           = lookup(local.config.dns, "create_zone", true) ? azurerm_dns_zone.this[0].name : local.config.dns.zone_name
  resource_group_name = local.config.azure.resource_group
  ttl                 = lookup(each.value, "ttl", 300)

  dynamic "record" {
    for_each = each.value.records
    content {
      value = record.value
    }
  }

  tags = local.tags
}

resource "azurerm_private_dns_zone" "this" {
  count = lookup(local.config.dns, "create_private_zone", false) ? 1 : 0

  name                = local.config.dns.private_zone_name
  resource_group_name = local.config.azure.resource_group

  tags = local.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = lookup(local.config.dns, "create_private_zone", false) ? toset(lookup(local.config.dns, "vnet_links", [])) : toset([])

  name                  = "${local.dns_name}-vnet-link-${each.key}"
  resource_group_name   = local.config.azure.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.this[0].name
  virtual_network_id    = each.value
  registration_enabled  = lookup(local.config.dns, "auto_registration", false)

  tags = local.tags
}
