resource "azurerm_kubernetes_cluster" "this" {
  name                = local.cluster_name
  location            = local.config.meta.region
  resource_group_name = local.config.azure.resource_group
  dns_prefix          = "${local.cluster_name}-dns"
  kubernetes_version  = local.config.cluster.kubernetes_version

  sku_tier = lookup(local.config.cluster, "sku_tier", "Standard")

  default_node_pool {
    name                = "system"
    vm_size             = lookup(local.config.cluster.default_node_pool, "vm_size", "Standard_D2s_v3")
    enable_auto_scaling = true
    min_count           = lookup(local.config.cluster.default_node_pool, "min_count", 1)
    max_count           = lookup(local.config.cluster.default_node_pool, "max_count", 5)
    node_count          = lookup(local.config.cluster.default_node_pool, "node_count", 2)
    os_disk_size_gb     = lookup(local.config.cluster.default_node_pool, "os_disk_size_gb", 128)
    os_disk_type        = lookup(local.config.cluster.default_node_pool, "os_disk_type", "Managed")
    vnet_subnet_id      = local.config.networking.subnet_id
    zones               = lookup(local.config.cluster.default_node_pool, "availability_zones", [1, 2, 3])
    node_labels         = lookup(local.config.cluster.default_node_pool, "node_labels", {})
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = lookup(local.config.cluster.network, "plugin", "azure")
    network_policy    = lookup(local.config.cluster.network, "policy", "azure")
    service_cidr      = lookup(local.config.cluster.network, "service_cidr", "10.0.0.0/16")
    dns_service_ip    = lookup(local.config.cluster.network, "dns_service_ip", "10.0.0.10")
    load_balancer_sku = "standard"
  }

  azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = lookup(local.config.cluster.azure_ad, "admin_group_object_ids", [])
    azure_rbac_enabled     = lookup(local.config.cluster.azure_ad, "azure_rbac_enabled", true)
  }

  oms_agent {
    log_analytics_workspace_id = lookup(local.config.cluster.addons, "log_analytics_workspace_id", null)
  }

  azure_policy_enabled = lookup(local.config.cluster.addons, "azure_policy", true)

  private_cluster_enabled = lookup(local.config.cluster, "private_cluster", true)

  tags = local.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = { for idx, np in lookup(local.config.cluster, "additional_node_pools", []) : idx => np }

  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  enable_auto_scaling   = true
  min_count             = lookup(each.value, "min_count", 1)
  max_count             = lookup(each.value, "max_count", 10)
  node_count            = lookup(each.value, "node_count", 2)
  os_disk_size_gb       = lookup(each.value, "os_disk_size_gb", 128)
  vnet_subnet_id        = local.config.networking.subnet_id
  zones                 = lookup(each.value, "availability_zones", [1, 2, 3])
  node_labels           = lookup(each.value, "node_labels", {})
  node_taints           = lookup(each.value, "node_taints", [])
  mode                  = lookup(each.value, "mode", "User")

  tags = local.tags
}
