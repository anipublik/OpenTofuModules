# Azure Compute Modules

Production-hardened compute resources for Azure with managed identities, disk encryption, and auto-scaling.

## Modules

### [VM](./vm/README.md)
Virtual Machines and Virtual Machine Scale Sets with:
- Managed Identity (system or user-assigned)
- Azure Disk Encryption
- Accelerated networking
- Boot diagnostics
- Azure Monitor agent
- Auto-scaling with metric-based rules

### [AKS](./aks/README.md)
Managed Kubernetes clusters with:
- Azure AD integration
- Private cluster option
- Workload Identity
- Managed node pools with availability zones
- Azure Policy add-on
- Container Insights monitoring

### [Functions](./functions/README.md)
Serverless functions with:
- VNet integration
- Managed Identity
- Application Insights
- Deployment slots
- Always On option
- Premium plan with VNET injection

### [Container Apps](./container-apps/README.md)
Serverless containers with:
- Dapr integration
- KEDA auto-scaling
- Ingress with custom domains
- Managed Identity
- Container Apps Environment with VNet integration
- Revision management

## Common Configuration

All compute modules share these YAML fields:

```yaml
meta:
  environment: production
  region: eastus
  name: my-compute
  team: platform
  cost_center: eng-001

azure:
  resource_group: rg-platform-prod
  subscription_id: "12345678-1234-1234-1234-123456789012"

compute:
  sku: Standard_D2s_v3            # VM, varies by module
  min_instances: 2                # Auto-scaling minimum
  max_instances: 10               # Auto-scaling maximum

networking:
  vnet_id: /subscriptions/.../virtualNetworks/vnet-prod
  subnet_id: /subscriptions/.../subnets/subnet-compute
  
monitoring:
  log_analytics_workspace_id: /subscriptions/.../workspaces/law-prod
  application_insights_key: "..."

security:
  encryption_enabled: true
  managed_identity: true
  public_access: false

tags:
  custom_tag: value
```

## Security Defaults

| Control | VM | AKS | Functions | Container Apps |
|---------|-----|-----|-----------|----------------|
| **Managed Identity** | ✓ | ✓ | ✓ | ✓ |
| **Disk Encryption** | ✓ | ✓ | N/A | N/A |
| **VNet Integration** | ✓ | ✓ | ✓ | ✓ |
| **Azure AD Auth** | ✓ | ✓ | ✓ | ✓ |
| **Private Endpoints** | ✓ | ✓ | ✓ | ✓ |
| **Diagnostic Logs** | ✓ | ✓ | ✓ | ✓ |

## Performance Defaults

- **Accelerated Networking** — Enabled on all VM SKUs that support it
- **Proximity Placement Groups** — Available for low-latency workloads
- **Premium Storage** — SSD-backed disks for production workloads
- **Always On** — Available for Functions to eliminate cold starts
- **Zone Redundancy** — Multi-zone deployment for high availability

## Quick Start

```bash
# Example: Deploy an AKS cluster
cd azure/compute/aks
cp examples/basic/config.yaml my-cluster.yaml

# Edit config
vim my-cluster.yaml

# Deploy
cat > main.tf << 'EOF'
module "aks" {
  source = "../../../azure/compute/aks"
  config_file = "my-cluster.yaml"
}
EOF

tofu init && tofu apply
```

## Outputs

All compute modules output:

```hcl
output "resource_id" { }
output "resource_name" { }
output "principal_id" { }           # Managed Identity
output "connection_endpoint" { }    # AKS, Container Apps
output "fqdn" { }                   # If applicable
```
