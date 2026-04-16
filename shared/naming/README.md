# Shared Naming Module

Generates deterministic, provider-aware resource names from YAML config.

## Inputs

- `cloud_provider` – One of `aws`, `azure`, `gcp`, `datadog`.
- `resource_type` – Logical resource type (e.g. `eks-cluster`, `rds-instance`).
- `config` – Decoded YAML config with required `environment`, `team`, `name` fields.

## Outputs

- `name` – The generated, length-validated resource name.
- `prefix` – `<environment>-<team>` prefix used across policies.

## Usage

```hcl
module "naming" {
  source = "../../shared/naming"

  cloud_provider = "aws"
  resource_type  = "eks-cluster"
  config         = yamldecode(file(var.config_file))
}
```

## Rules

- Lowercase alphanumeric plus hyphens.
- Length capped per provider constraints (AWS: 32, Azure: 24, GCP: 30).
- Must start with `<environment>-<team>` — enforced via precondition in `terraform_data.validate_length`.
