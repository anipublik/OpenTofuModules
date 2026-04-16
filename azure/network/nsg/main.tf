resource "azurerm_network_security_group" "this" {
  name                = local.nsg_name
  location            = local.config.meta.region
  resource_group_name = local.config.azure.resource_group

  tags = local.tags
}

resource "azurerm_network_security_rule" "this" {
  for_each = { for idx, rule in lookup(local.config.nsg, "rules", []) : idx => rule }

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = lookup(each.value, "source_port_range", "*")
  destination_port_range      = lookup(each.value, "destination_port_range", null)
  destination_port_ranges     = lookup(each.value, "destination_port_ranges", null)
  source_address_prefix       = lookup(each.value, "source_address_prefix", null)
  source_address_prefixes     = lookup(each.value, "source_address_prefixes", null)
  destination_address_prefix  = lookup(each.value, "destination_address_prefix", null)
  destination_address_prefixes = lookup(each.value, "destination_address_prefixes", null)
  resource_group_name         = local.config.azure.resource_group
  network_security_group_name = azurerm_network_security_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = toset(lookup(local.config.nsg, "subnet_ids", []))

  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.this.id
}
