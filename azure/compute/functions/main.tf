resource "azurerm_storage_account" "functions" {
  name                     = "${replace(local.function_name, "-", "")}sa"
  resource_group_name      = local.config.azure.resource_group
  location                 = local.config.meta.region
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = local.tags
}

resource "azurerm_service_plan" "this" {
  name                = "${local.function_name}-plan"
  location            = local.config.meta.region
  resource_group_name = local.config.azure.resource_group
  os_type             = lookup(local.config.function, "os_type", "Linux")
  sku_name            = lookup(local.config.function, "sku_name", "Y1")

  tags = local.tags
}

resource "azurerm_linux_function_app" "this" {
  name                = local.function_name
  location            = local.config.meta.region
  resource_group_name = local.config.azure.resource_group
  service_plan_id     = azurerm_service_plan.this.id

  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key

  site_config {
    always_on = lookup(local.config.function, "always_on", false)

    application_stack {
      python_version = lookup(local.config.function, "python_version", "3.9")
    }

    application_insights_connection_string = lookup(local.config.function, "app_insights_connection_string", null)
    application_insights_key               = lookup(local.config.function, "app_insights_key", null)
  }

  app_settings = merge(
    lookup(local.config.function, "app_settings", {}),
    {
      "FUNCTIONS_WORKER_RUNTIME" = lookup(local.config.function, "runtime", "python")
    }
  )

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_function_app_function" "this" {
  for_each = { for idx, func in lookup(local.config.function, "functions", []) : idx => func }

  name            = each.value.name
  function_app_id = azurerm_linux_function_app.this.id
  language        = lookup(local.config.function, "runtime", "python")

  file {
    name    = "__init__.py"
    content = lookup(each.value, "code", "# Function code here")
  }

  config_json = jsonencode({
    bindings = lookup(each.value, "bindings", [])
  })
}
