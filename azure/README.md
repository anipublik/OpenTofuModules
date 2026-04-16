# Azure Modules

Production-hardened OpenTofu modules for Microsoft Azure.

## Overview

This directory contains YAML-driven modules for Azure infrastructure. Every module enforces Azure security best practices, CIS benchmark compliance, and operational excellence patterns by default.

## Module Categories

### [Compute](./compute/README.md)
Deploy VMs, AKS clusters, Azure Functions, and Container Apps with managed identities, disk encryption, and auto-scaling.

- **[VM](./compute/vm/README.md)** — Standalone VMs and Virtual Machine Scale Sets
- **[AKS](./compute/aks/README.md)** — Managed Kubernetes with Azure AD integration and private clusters
- **[Functions](./compute/functions/README.md)** — Serverless functions with VNet integration and App Insights
- **[Container Apps](./compute/container-apps/README.md)** — Serverless containers with Dapr and KEDA

### [Network](./network/README.md)
Build VNets, NSGs, Application Gateways, and DNS with flow logs, Private Link, and DDoS protection.

- **[VNet](./network/vnet/README.md)** — Virtual networks with subnets and service endpoints
- **[NSG](./network/nsg/README.md)** — Network security groups with deny-by-default rules
- **[Application Gateway](./network/app-gateway/README.md)** — Layer 7 load balancer with WAF
- **[Azure DNS](./network/dns/README.md)** — Public and private DNS zones
- **[Azure Front Door](./network/front-door/README.md)** — Global CDN with WAF and routing

### [Storage](./storage/README.md)
Provision Blob storage, Azure SQL, CosmosDB, and Redis Cache with encryption, geo-replication, and lifecycle policies.

- **[Blob Storage](./storage/blob/README.md)** — Storage accounts with versioning and soft delete
- **[Azure SQL](./storage/sql/README.md)** — Managed SQL databases with TDE and auditing
- **[CosmosDB](./storage/cosmosdb/README.md)** — Multi-model NoSQL with global distribution
- **[Azure Cache for Redis](./storage/redis/README.md)** — In-memory cache with clustering

### [Security](./security/README.md)
Manage Key Vault secrets, managed identities, and Azure Policy with RBAC and audit logging.

- **[Key Vault](./security/key-vault/README.md)** — Secret, key, and certificate management with soft delete
- **[Managed Identity](./security/managed-identity/README.md)** — User-assigned and system-assigned identities
- **[Azure Policy](./security/policy/README.md)** — Policy assignments for compliance enforcement

### [Messaging](./messaging/README.md)
Deploy Service Bus queues, Event Grid topics, and Event Hubs with encryption and dead-letter queues.

- **[Service Bus](./messaging/service-bus/README.md)** — Enterprise messaging with sessions and transactions
- **[Event Grid](./messaging/event-grid/README.md)** — Event routing with filtering and retry policies
- **[Event Hub](./messaging/event-hub/README.md)** — Big data streaming with capture to storage

### [Observability](./observability/README.md)
Configure Log Analytics workspaces, diagnostic settings, and Azure Monitor alerts with retention policies.

- **[Log Analytics](./observability/log-analytics/README.md)** — Centralized logging with KQL queries
- **[Diagnostic Settings](./observability/diagnostics/README.md)** — Resource-level logging to Log Analytics
- **[Azure Monitor Alert](./observability/monitor-alert/README.md)** — Metric and log-based alerting

## Azure-Specific Security Defaults

| Control | Implementation |
|---------|---------------|
| **Managed Identity** | Enabled on all compute resources; no service principal credentials in code |
| **Storage HTTPS** | `https_traffic_only_enabled = true` on all storage accounts |
| **TDE** | Transparent Data Encryption enabled on Azure SQL and CosmosDB |
| **Key Vault Soft Delete** | Enabled with 90-day retention on all Key Vaults |
| **NSG Flow Logs** | Enabled on all NSGs with Log Analytics destination |
| **Azure Policy** | Built-in policies assigned for encryption, auditing, and network isolation |
| **Private Endpoints** | Available for all PaaS services (SQL, Storage, Key Vault, etc.) |
| **Disk Encryption** | Azure Disk Encryption enabled on all VM disks |

## Common YAML Schema

All Azure modules extend the base schema with Azure-specific fields:

```yaml
meta:
  environment: production
  region: eastus
  name: my-resource
  team: platform
  cost_center: eng-001

azure:
  subscription_id: "12345678-1234-1234-1234-123456789012"  # Optional
  resource_group: "rg-platform-prod"                       # Required for most modules
  key_vault_id: "/subscriptions/.../keyVault"              # Optional — for encryption

tags:
  custom_tag: value

security:
  encryption_enabled: true
  public_access: false
  deletion_protection: true
  audit_logging: true

reliability:
  zone_redundant: true              # Azure equivalent of multi_az
  backup_retention_days: 7
  geo_replication: false            # Opt-in for cross-region replication
```

## Provider Configuration

All modules require the AzureRM provider `>= 3.0`:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.7.0"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
}
```

## Quick Start Example

```bash
# Navigate to AKS module
cd azure/compute/aks

# Copy example config
cp examples/basic/config.yaml my-cluster.yaml

# Edit with your values
vim my-cluster.yaml

# Create main.tf
cat > main.tf << 'EOF'
module "aks" {
  source = "../../../azure/compute/aks"
  config_file = "my-cluster.yaml"
}

output "cluster_fqdn" {
  value = module.aks.cluster_fqdn
}
EOF

# Deploy
tofu init
tofu apply
```

## Private Endpoints

All network-aware modules (AKS, Functions, Container Apps) support Private Link to keep traffic within the VNet. The VNet module includes pre-configured service endpoints for:

- Azure Storage (Blob, File, Queue, Table)
- Azure SQL Database
- Azure Key Vault
- Azure Container Registry
- Azure Cosmos DB

## Cost Optimization

Azure modules include cost-aware defaults:

- **VM** — B-series burstable instances for dev/test workloads
- **Azure SQL** — Serverless tier available with auto-pause
- **Storage** — Cool and Archive tiers with lifecycle management
- **AKS** — Spot node pools available for fault-tolerant workloads
- **Functions** — Consumption plan default with Premium plan opt-in

## Compliance

All modules align with:

- **CIS Microsoft Azure Foundations Benchmark v2.0.0**
- **Azure Well-Architected Framework** (Security, Reliability, Performance Efficiency pillars)
- **NIST 800-53** controls (encryption, audit logging, least privilege)
- **ISO 27001** and **SOC 2** requirements

## Support

For Azure-specific issues:
1. Check the module's README for troubleshooting guidance
2. Review AzureRM provider documentation for resource-specific constraints
3. Open an issue with `[Azure]` prefix in the title

## Additional Resources

- [AzureRM Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/architecture/framework/)
- [CIS Azure Foundations Benchmark](https://www.cisecurity.org/benchmark/azure)
