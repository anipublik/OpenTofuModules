# Validation module for YAML config schema validation.
# Uses terraform_data lifecycle preconditions so error messages surface
# cleanly at plan time instead of the historical tobool() conversion trick.

locals {
  config = var.config

  valid_environments = ["dev", "development", "staging", "stage", "prod", "production"]
}

resource "terraform_data" "validate" {
  input = {
    cloud_provider = var.cloud_provider
    resource_type  = var.resource_type
  }

  lifecycle {
    precondition {
      condition     = can(local.config.meta.environment)
      error_message = "meta.environment is required in the YAML config."
    }
    precondition {
      condition     = can(local.config.meta.region)
      error_message = "meta.region is required in the YAML config."
    }
    precondition {
      condition     = can(local.config.meta.name)
      error_message = "meta.name is required in the YAML config."
    }
    precondition {
      condition     = can(local.config.meta.team)
      error_message = "meta.team is required in the YAML config."
    }
    precondition {
      condition     = can(local.config.meta.cost_center)
      error_message = "meta.cost_center is required in the YAML config."
    }
    precondition {
      condition     = contains(local.valid_environments, try(local.config.meta.environment, ""))
      error_message = "meta.environment must be one of: dev, development, staging, stage, prod, production."
    }
    precondition {
      # Note: provider-specific length limits on the full generated name are enforced
      # by shared/naming. Here we only validate input-string format.
      condition     = can(regex("^[a-z0-9-]+$", try(local.config.meta.name, "")))
      error_message = "meta.name must contain only lowercase letters, numbers, and hyphens."
    }
    precondition {
      condition     = !can(local.config.security.encryption_enabled) || local.config.security.encryption_enabled == true
      error_message = "security.encryption_enabled must be true when set."
    }
    precondition {
      condition     = !can(local.config.security.public_access) || local.config.security.public_access == false
      error_message = "security.public_access must be false when set."
    }
  }
}
