locals {
  required_tags = {
    environment = var.environment
    team        = var.team
    cost_center = var.cost_center
    managed_by  = "opentofu"
    module      = var.module_path
  }

  # Merge required tags with custom tags, required tags take precedence
  tags = merge(var.custom_tags, local.required_tags)

  labels = {
    for key, value in local.tags :
    substr(replace(lower(key), "/[^a-z0-9_-]/", "_"), 0, 63) => substr(replace(lower(value), "/[^a-z0-9_-]/", "_"), 0, 63)
  }

  valid_environments = ["dev", "development", "staging", "stage", "prod", "production"]
}

resource "terraform_data" "validate" {
  input = {
    module_path = var.module_path
  }

  lifecycle {
    precondition {
      condition     = contains(local.valid_environments, var.environment)
      error_message = "tagging.environment must be one of: dev, development, staging, stage, prod, production."
    }
    precondition {
      condition     = length(var.team) > 0
      error_message = "tagging.team is required."
    }
    precondition {
      condition     = length(var.cost_center) > 0
      error_message = "tagging.cost_center is required."
    }
  }
}
