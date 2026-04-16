# Azure AKS Module

Production-hardened Azure Kubernetes Service cluster with Azure AD integration, private clusters, and Workload Identity.

## Features

- **Azure AD Integration** — RBAC with Azure AD groups
- **Private Cluster** — Optional private API server endpoint
- **Workload Identity** — Pod-level Azure AD authentication
- **Managed Node Pools** — Availability zone distribution
- **Azure Policy** — Policy enforcement at cluster level
- **Container Insights** — Monitoring with Log Analytics
- **Network Policies** — Azure Network Policy or Calico
- **Managed Identity** — System-assigned or user-assigned

## YAML Configuration

```yaml
meta:
  environment: production
  region: eastus
  name: platform-aks
  team: platform
  cost_center: eng-001

azure:
  resource_group: rg-platform-prod
  subscription_id: "12345678-1234-1234-1234-123456789012"

cluster:
  kubernetes_version: "1.29"
  sku_tier: Standard                 # or Free
  private_cluster: true
  private_dns_zone_id: "System"      # or custom private DNS zone ID
  
  network:
    plugin: azure                    # or kubenet
    policy: azure                    # or calico
    service_cidr: 10.0.0.0/16
    dns_service_ip: 10.0.0.10
    pod_cidr: 10.244.0.0/16          # Required for kubenet
  
  identity:
    type: SystemAssigned             # or UserAssigned
    user_assigned_identity_id: "..." # If UserAssigned
  
  azure_ad:
    enabled: true
    managed: true
    admin_group_object_ids:
      - "11111111-1111-1111-1111-111111111111"
    azure_rbac_enabled: true
  
  addons:
    azure_policy: true
    oms_agent: true
    log_analytics_workspace_id: /subscriptions/.../workspaces/law-prod

networking:
  vnet_id: /subscriptions/.../virtualNetworks/vnet-prod
  subnet_id: /subscriptions/.../subnets/subnet-aks
  outbound_type: loadBalancer        # or userDefinedRouting

node_pools:
  - name: system
    mode: System
    vm_size: Standard_D4s_v3
    os_disk_size_gb: 128
    os_disk_type: Managed
    enable_auto_scaling: true
    min_count: 2
    max_count: 5
    node_count: 3
    availability_zones:
      - 1
      - 2
      - 3
    node_labels:
      workload: system
    node_taints: []
    
  - name: user
    mode: User
    vm_size: Standard_D8s_v3
    os_disk_size_gb: 256
    enable_auto_scaling: true
    min_count: 1
    max_count: 20
    node_count: 3
    availability_zones:
      - 1
      - 2
      - 3
    node_labels:
      workload: application
    node_taints: []

security:
  encryption_enabled: true
  public_access: false
  deletion_protection: true
  audit_logging: true

monitoring:
  log_analytics_workspace_id: /subscriptions/.../workspaces/law-prod
  
tags:
  project: platform
  compliance: hipaa
```

## Usage

```hcl
module "aks" {
  source = "./azure/compute/aks"
  config_file = "aks-cluster.yaml"
}

output "cluster_fqdn" {
  value = module.aks.cluster_fqdn
}

output "cluster_id" {
  value = module.aks.cluster_id
}

output "kubelet_identity_object_id" {
  value = module.aks.kubelet_identity_object_id
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `cluster_id` | AKS cluster resource ID |
| `cluster_name` | AKS cluster name |
| `cluster_fqdn` | Kubernetes API FQDN |
| `kube_config` | Kubernetes config (sensitive) |
| `principal_id` | Cluster managed identity principal ID |
| `kubelet_identity_object_id` | Kubelet managed identity object ID |
| `oidc_issuer_url` | OIDC issuer URL for Workload Identity |
| `node_resource_group` | Node resource group name |

## Workload Identity Setup

The module enables Workload Identity. To create a federated credential:

```bash
# Create user-assigned managed identity
az identity create \
  --name app-identity \
  --resource-group rg-platform-prod

# Create federated credential
az identity federated-credential create \
  --name app-federated-credential \
  --identity-name app-identity \
  --resource-group rg-platform-prod \
  --issuer $(az aks show -n platform-aks-production -g rg-platform-prod --query "oidcIssuerProfile.issuerUrl" -o tsv) \
  --subject system:serviceaccount:default:my-service-account
```

Kubernetes service account:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-service-account
  namespace: default
  annotations:
    azure.workload.identity/client-id: "CLIENT_ID_OF_MANAGED_IDENTITY"
```

## kubectl Configuration

```bash
az aks get-credentials \
  --resource-group rg-platform-prod \
  --name platform-aks-production \
  --admin  # Use --admin for private clusters or Azure AD issues
```

## Security Considerations

- **Private Cluster** — Set `private_cluster: true` for maximum security
- **Azure AD RBAC** — Use `azure_rbac_enabled: true` for fine-grained access control
- **Network Policy** — Enable Azure Network Policy or Calico for pod-to-pod security
- **Workload Identity** — Use instead of pod-managed identity for better security
- **Azure Policy** — Enforce security policies at cluster level
- **Authorized IP Ranges** — Restrict API server access to known IPs (if not private)

## Cost Optimization

- **Free Tier** — Use `sku_tier: Free` for dev/test clusters
- **Spot Node Pools** — Add spot node pools for fault-tolerant workloads
- **Cluster Autoscaler** — Automatically enabled with `enable_auto_scaling: true`
- **Start/Stop** — Use AKS start/stop feature for non-production clusters
- **Node Pool Scaling** — Set appropriate min/max counts based on workload

## Troubleshooting

**Nodes not ready:**
- Check subnet has sufficient IP addresses
- Verify NSG allows required traffic
- Check route table if using `outbound_type: userDefinedRouting`

**Can't access API server:**
- For private clusters, ensure you're on VNet or using VPN/ExpressRoute
- Verify Azure AD group membership for RBAC
- Check authorized IP ranges if configured

**Workload Identity not working:**
- Verify OIDC issuer is enabled on cluster
- Check federated credential subject matches service account
- Ensure service account has correct annotation

## Additional Resources

- [AKS Best Practices](https://learn.microsoft.com/en-us/azure/aks/best-practices)
- [AKS Documentation](https://learn.microsoft.com/en-us/azure/aks/)
- [Workload Identity](https://learn.microsoft.com/en-us/azure/aks/workload-identity-overview)
