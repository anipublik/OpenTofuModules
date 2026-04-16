resource "azurerm_container_app_environment" "this" {
  name                       = "${local.app_name}-env"
  location                   = local.config.meta.region
  resource_group_name        = local.config.azure.resource_group
  log_analytics_workspace_id = local.config.container_app.log_analytics_workspace_id

  infrastructure_subnet_id = lookup(local.config.networking, "subnet_id", null)

  tags = local.tags
}

resource "azurerm_container_app" "this" {
  name                         = local.app_name
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = local.config.azure.resource_group
  revision_mode                = lookup(local.config.container_app, "revision_mode", "Single")

  template {
    min_replicas = lookup(local.config.container_app, "min_replicas", 0)
    max_replicas = lookup(local.config.container_app, "max_replicas", 10)

    container {
      name   = local.config.container_app.container_name
      image  = local.config.container_app.image
      cpu    = lookup(local.config.container_app, "cpu", 0.25)
      memory = lookup(local.config.container_app, "memory", "0.5Gi")

      dynamic "env" {
        for_each = lookup(local.config.container_app, "environment_variables", {})
        content {
          name  = env.key
          value = env.value
        }
      }
    }
  }

  dynamic "ingress" {
    for_each = lookup(local.config.container_app, "ingress", null) != null ? [1] : []
    content {
      external_enabled = lookup(local.config.container_app.ingress, "external_enabled", true)
      target_port      = local.config.container_app.ingress.target_port

      traffic_weight {
        percentage      = 100
        latest_revision = true
      }
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}
