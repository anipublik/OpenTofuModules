# Shared Modules

Cross-provider utilities for consistent tagging, naming, validation, and common patterns.

## Modules

### [Tagging](./tagging/README.md)
Enforces required tag schema across all resources:
- Required tags: `environment`, `team`, `cost_center`, `managed_by`, `module`
- Merges custom tags from YAML
- Validates tag presence before plan
- Provider-specific tag format handling

### [Naming](./naming/README.md)
Generates consistent resource names:
- Pattern: `{environment}-{team}-{resource_type}-{name}`
- Length constraints per provider
- Outputs for dependent resources
- Handles provider-specific naming rules (Azure lowercase, GCP hyphens, etc.)

### [Validation](./validation/README.md)
Input validation and policy checks:
- YAML schema validation
- CIDR block validation
- Region/zone validation per provider
- Security baseline checks
- OPA policy integration

### [Locals](./locals/README.md)
Common local value patterns:
- YAML decode helpers
- Conditional logic patterns
- Map transformations
- Provider-specific defaults

## Usage

Shared modules are imported by resource modules automatically. You don't typically call them directly.

Example internal usage in a resource module:

```hcl
# In aws/compute/ec2/locals.tf
module "naming" {
  source = "../../../shared/naming"
  
  environment = local.config.meta.environment
  team = local.config.meta.team
  resource_type = "ec2"
  name = local.config.meta.name
  provider = "aws"
}

module "tagging" {
  source = "../../../shared/tagging"
  
  required_tags = {
    environment = local.config.meta.environment
    team = local.config.meta.team
    cost_center = local.config.meta.cost_center
    managed_by = "opentofu"
    module = "aws/compute/ec2"
  }
  
  custom_tags = lookup(local.config, "tags", {})
}

locals {
  resource_name = module.naming.name
  tags = module.tagging.tags
}
```

## Tagging Schema

All modules enforce this tag schema:

| Tag | Required | Source | Example |
|-----|----------|--------|---------|
| `environment` | Yes | YAML `meta.environment` | `production` |
| `team` | Yes | YAML `meta.team` | `platform` |
| `cost_center` | Yes | YAML `meta.cost_center` | `eng-001` |
| `managed_by` | Yes | Hardcoded | `opentofu` |
| `module` | Yes | Module path | `aws/compute/eks` |
| Custom tags | No | YAML `tags` | `project: api` |

## Naming Convention

Generated names follow this pattern:

```
{environment}-{team}-{resource_type}-{name}
```

Examples:
- `production-platform-eks-api-cluster`
- `staging-data-rds-analytics-db`
- `dev-frontend-s3-assets-bucket`

Provider-specific adjustments:
- **AWS** — Hyphens, mixed case allowed
- **Azure** — Lowercase, hyphens (some resources don't allow hyphens)
- **GCP** — Lowercase, hyphens only

## Validation Rules

The validation module checks:

1. **Required fields** — `meta.environment`, `meta.region`, `meta.name`, `meta.team`, `meta.cost_center`
2. **Environment values** — Must be one of: `dev`, `staging`, `production`
3. **Region format** — Valid region for the provider
4. **CIDR blocks** — Valid IPv4 CIDR notation
5. **Security baselines** — `encryption_enabled: true`, `public_access: false`, etc.

## Contributing

When adding new shared modules:
1. Keep them provider-agnostic where possible
2. Use `provider` parameter to handle provider-specific logic
3. Document all inputs and outputs
4. Include validation tests
5. Update this README with the new module
