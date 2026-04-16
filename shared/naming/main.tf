locals {
  # Generate name following pattern: {environment}-{team}-{resource_type}-{name}
  generated_name = "${var.environment}-${var.team}-${var.resource_type}-${var.name}"

  # Apply provider-specific constraints
  name = var.cloud_provider == "azure" ? lower(local.generated_name) : local.generated_name

  # Provider-specific length limits
  provider_limits = {
    aws     = 255
    azure   = 64
    gcp     = 63
    datadog = 200
  }

  max_length = lookup(local.provider_limits, var.cloud_provider, 255)
}

resource "terraform_data" "validate" {
  input = {
    cloud_provider = var.cloud_provider
    name           = local.name
  }

  lifecycle {
    precondition {
      condition     = length(local.name) <= local.max_length
      error_message = "Generated name '${local.name}' (${length(local.name)} chars) exceeds the ${local.max_length}-character limit for provider '${var.cloud_provider}'."
    }
  }
}
