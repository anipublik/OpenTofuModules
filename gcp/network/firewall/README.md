# GCP Firewall Module

Production-hardened VPC firewall rules with logging.

## Features

- **Allow/Deny Rules** — Traffic filtering
- **Priority-Based** — Rule ordering
- **Source/Target Tags** — Instance targeting
- **Logging** — Flow logs for all rules

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: app-firewall
  team: platform
  cost_center: eng-001

firewall:
  rules:
    - name: allow-https
      direction: INGRESS
      priority: 1000
      source_ranges:
        - 0.0.0.0/0
      target_tags:
        - web-server
      allow:
        - protocol: tcp
          ports:
            - "443"
    
    - name: deny-all
      direction: INGRESS
      priority: 65534
      source_ranges:
        - 0.0.0.0/0
      deny:
        - protocol: all

networking:
  network: projects/my-project/global/networks/main

gcp:
  project_id: my-project

tags:
  security_tier: application
```

## Usage

```hcl
module "firewall" {
  source = "./gcp/network/firewall"
  config_file = "firewall.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | First firewall rule ID |
| `firewall_rule_ids` | Map of firewall rule IDs |
