# GCP VPC Service Controls Module

Production-hardened VPC Service Controls with access levels and perimeters.

## Features

- **Access Policies** — Organization-level policies
- **Access Levels** — Context-based access
- **Service Perimeters** — Resource boundaries
- **Ingress/Egress Policies** — Traffic control

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: security-perimeter
  team: platform
  cost_center: eng-001

vpc_sc:
  create_access_policy: false
  access_policy_name: "123456789012"
  
  access_levels:
    - name: corporate-network
      conditions:
        - ip_subnetworks:
            - 203.0.113.0/24
  
  service_perimeters:
    - name: production-perimeter
      perimeter_type: PERIMETER_TYPE_REGULAR
      resources:
        - projects/123456789012
      restricted_services:
        - storage.googleapis.com
        - bigquery.googleapis.com
      access_level_indices:
        - 0

gcp:
  project_id: my-project
  organization_id: "123456789012"

tags:
  security_tier: high
```

## Usage

```hcl
module "vpc_sc" {
  source = "./gcp/security/vpc-sc"
  config_file = "vpc-sc.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Access policy ID |
| `access_level_names` | Map of access level names |
| `service_perimeter_names` | Map of perimeter names |
