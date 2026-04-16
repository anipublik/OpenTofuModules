resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                = local.vmss_name
  location            = local.config.meta.region
  resource_group_name = local.config.azure.resource_group
  sku                 = local.config.vm.sku
  instances           = lookup(local.config.vm, "instances", 2)
  admin_username      = local.config.vm.admin_username

  admin_ssh_key {
    username   = local.config.vm.admin_username
    public_key = local.config.vm.ssh_public_key
  }

  source_image_reference {
    publisher = lookup(local.config.vm.image, "publisher", "Canonical")
    offer     = lookup(local.config.vm.image, "offer", "0001-com-ubuntu-server-focal")
    sku       = lookup(local.config.vm.image, "sku", "20_04-lts-gen2")
    version   = lookup(local.config.vm.image, "version", "latest")
  }

  os_disk {
    storage_account_type = lookup(local.config.vm, "os_disk_type", "Premium_LRS")
    caching              = "ReadWrite"
    disk_size_gb         = lookup(local.config.vm, "os_disk_size_gb", 30)
  }

  network_interface {
    name    = "${local.vmss_name}-nic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = local.config.networking.subnet_id
    }
  }

  identity {
    type = "SystemAssigned"
  }

  automatic_os_upgrade_policy {
    disable_automatic_rollback  = false
    enable_automatic_os_upgrade = true
  }

  automatic_instance_repair {
    enabled      = true
    grace_period = "PT30M"
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  tags = local.tags
}

resource "azurerm_monitor_autoscale_setting" "this" {
  name                = "${local.vmss_name}-autoscale"
  location            = local.config.meta.region
  resource_group_name = local.config.azure.resource_group
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.this.id

  profile {
    name = "default"

    capacity {
      default = lookup(local.config.vm, "instances", 2)
      minimum = lookup(local.config.vm.autoscaling, "min_instances", 1)
      maximum = lookup(local.config.vm.autoscaling, "max_instances", 10)
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.this.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = lookup(local.config.vm.autoscaling, "scale_out_cpu_threshold", 70)
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.this.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = lookup(local.config.vm.autoscaling, "scale_in_cpu_threshold", 30)
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }

  tags = local.tags
}
