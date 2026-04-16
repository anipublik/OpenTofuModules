# Azure Policy Module

Production-hardened Azure Policy with custom definitions and assignments.

## Features

- **Custom Policies** — Policy definitions
- **Policy Assignments** — Resource/subscription scope
- **Managed Identity** — Remediation support
- **Parameters** — Configurable policies

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: require-tags
  team: platform
  cost_center: eng-001

policy:
  create_definition: true
  mode: All
  display_name: Require specific tags
  description: Enforces required tags on resources
  category: Tags
  
  policy_rule:
    if:
      not:
        field: tags
        containsKey: environment
    then:
      effect: deny
  
  assign_to_resource_group: true
  enforce: true

azure:
  resource_group: production-rg
  resource_group_id: /subscriptions/.../resourceGroups/production-rg

tags:
  compliance: required
```

## Usage

```hcl
module "policy" {
  source = "./azure/security/policy"
  config_file = "policy.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Policy definition/assignment ID |
| `policy_definition_id` | Policy definition ID |
