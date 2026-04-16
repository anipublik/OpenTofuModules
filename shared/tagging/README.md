# Shared Tagging Module

Produces the canonical tag map enforced by OPA policies and expected by every resource module.

## Inputs

- `config` – Decoded YAML config providing `environment`, `team`, `cost_center`, and optional `tags`.
- `resource_type` – Logical resource type recorded in the `managed_by` tag.

## Outputs

- `tags` – Merged map of required + custom tags, sanitized for provider restrictions.

## Required Tags

All resources created via these modules are tagged with:

- `environment`
- `team`
- `cost_center`
- `managed_by` (always `opentofu`)
- `resource_type`

Custom tags from `config.tags` are merged last but cannot overwrite required tags — enforced via precondition in `terraform_data.validate_tags`.

## Usage

```hcl
module "tagging" {
  source = "../../shared/tagging"

  config        = yamldecode(file(var.config_file))
  resource_type = "eks-cluster"
}
```
