# Shared Validation Module

Validates YAML configuration schema and enforces security defaults.

## Features

- Required field validation
- Environment value validation
- Security defaults enforcement
- Naming constraint validation
- Provider-specific validation

## Usage

```hcl
module "validation" {
  source = "../../shared/validation"
  
  config        = yamldecode(file(var.config_file))
  provider      = "aws"
  resource_type = "eks-cluster"
}

locals {
  config = module.validation.config
}
```

## Validations

- **Required Fields**: environment, region, name, team, cost_center
- **Environment Values**: dev, development, staging, stage, prod, production
- **Security Defaults**: encryption_enabled, public_access
- **Naming**: Max 32 chars, lowercase alphanumeric with hyphens
