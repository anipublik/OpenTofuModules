# Azure Container Apps Module

Production-hardened Azure Container Apps with auto-scaling and managed identity.

## Features

- **Auto Scaling** — HTTP-based scaling
- **Managed Identity** — System-assigned identity
- **Ingress** — HTTPS endpoints
- **Revisions** — Traffic splitting
- **Secrets** — Environment variable secrets

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: api-service
  team: platform
  cost_center: eng-001

container_app:
  log_analytics_workspace_id: /subscriptions/.../workspaces/logs
  revision_mode: Single
  
  container_name: api
  image: myregistry.azurecr.io/api:latest
  cpu: 0.5
  memory: 1Gi
  
  min_replicas: 2
  max_replicas: 10
  
  environment_variables:
    ENV: production
  
  ingress:
    external_enabled: true
    target_port: 8080

networking:
  subnet_id: /subscriptions/.../subnets/container-apps

azure:
  resource_group: production-rg

tags:
  application: api
```

## Usage

```hcl
module "container_apps" {
  source = "./azure/compute/container-apps"
  config_file = "container-apps.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Container App ID |
| `container_app_fqdn` | Container App FQDN |
