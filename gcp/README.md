# GCP Modules

Production-hardened OpenTofu modules for Google Cloud Platform.

## Overview

This directory contains YAML-driven modules for GCP infrastructure. Every module enforces GCP security best practices, CIS benchmark compliance, and operational excellence patterns by default.

## Module Categories

### [Compute](./compute/README.md)
Deploy GCE instances, GKE clusters, Cloud Run services, and Cloud Functions with service accounts, disk encryption, and auto-scaling.

- **[GCE](./compute/gce/README.md)** — Compute Engine instances and Managed Instance Groups
- **[GKE](./compute/gke/README.md)** — Managed Kubernetes with Workload Identity and private clusters
- **[Cloud Run](./compute/cloud-run/README.md)** — Serverless containers with VPC connectors and IAM authentication
- **[Cloud Functions](./compute/functions/README.md)** — Event-driven functions with VPC access and Cloud Trace

### [Network](./network/README.md)
Build VPCs, firewall rules, load balancers, and DNS with VPC Flow Logs, Private Service Connect, and Cloud Armor.

- **[VPC](./network/vpc/README.md)** — Custom mode VPCs with subnets and Private Google Access
- **[Firewall Rules](./network/firewall/README.md)** — Deny-by-default ingress and egress rules
- **[Cloud Load Balancing](./network/load-balancing/README.md)** — Global HTTP(S), TCP/SSL, and internal load balancers
- **[Cloud DNS](./network/dns/README.md)** — Public and private managed zones
- **[Cloud CDN](./network/cdn/README.md)** — Content delivery with cache invalidation

### [Storage](./storage/README.md)
Provision GCS buckets, Cloud SQL databases, Spanner instances, and Memorystore with encryption, backups, and replication.

- **[GCS](./storage/gcs/README.md)** — Cloud Storage buckets with versioning and lifecycle policies
- **[Cloud SQL](./storage/cloudsql/README.md)** — MySQL, PostgreSQL with automated backups and HA
- **[Spanner](./storage/spanner/README.md)** — Globally distributed relational database
- **[Memorystore](./storage/memorystore/README.md)** — Redis and Memcached with in-transit encryption

### [Security](./security/README.md)
Manage KMS key rings, Secret Manager secrets, and IAM bindings with least-privilege policies and audit logging.

- **[KMS](./security/kms/README.md)** — Cloud KMS key rings with automatic rotation
- **[Secret Manager](./security/secret-manager/README.md)** — Secret storage with versioning and replication
- **[IAM Binding](./security/iam/README.md)** — Project, folder, and organization-level IAM policies
- **[VPC Service Controls](./security/vpc-sc/README.md)** — Perimeter-based access control for APIs

### [Messaging](./messaging/README.md)
Deploy Pub/Sub topics and Cloud Tasks queues with encryption and dead-letter topics.

- **[Pub/Sub](./messaging/pubsub/README.md)** — Topics and subscriptions with message retention
- **[Cloud Tasks](./messaging/tasks/README.md)** — Asynchronous task execution with rate limiting

### [Observability](./observability/README.md)
Configure Cloud Logging sinks, monitoring alert policies, and Cloud Audit Logs with retention policies.

- **[Log Sink](./observability/log-sink/README.md)** — Export logs to Cloud Storage, BigQuery, or Pub/Sub
- **[Monitoring Alert](./observability/alert/README.md)** — Metric and log-based alerting with notification channels
- **[Cloud Audit Logs](./observability/audit-logs/README.md)** — Admin, data access, and system event logs

## GCP-Specific Security Defaults

| Control | Implementation |
|---------|---------------|
| **Workload Identity** | Enabled on GKE; no service account keys in code |
| **Uniform Bucket Access** | Enforced on all GCS buckets (no ACLs) |
| **CMEK** | Customer-managed encryption keys for all storage resources |
| **Private Google Access** | Enabled on all VPC subnets for API access without public IPs |
| **VPC Flow Logs** | Enabled on all subnets with Cloud Logging destination |
| **Cloud Audit Logs** | Admin and data access logs enabled for all services |
| **Shielded VMs** | Secure Boot, vTPM, and integrity monitoring enabled on all GCE instances |
| **Binary Authorization** | Available for GKE and Cloud Run to enforce signed container images |

## Common YAML Schema

All GCP modules extend the base schema with GCP-specific fields:

```yaml
meta:
  environment: production
  region: us-central1
  name: my-resource
  team: platform
  cost_center: eng-001

gcp:
  project_id: "my-gcp-project"                    # Required
  kms_key_name: "projects/.../keyRings/.../..."   # Optional — for CMEK

labels:                                            # GCP uses labels instead of tags
  custom_label: value

security:
  encryption_enabled: true
  public_access: false
  deletion_protection: true
  audit_logging: true

reliability:
  regional: true                                   # GCP equivalent of multi_az
  backup_retention_days: 7
  multi_region: false                              # Opt-in for cross-region replication
```

## Provider Configuration

All modules require the Google provider `>= 5.0`:

```hcl
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.7.0"
}

provider "google" {
  project = "my-gcp-project"
  region  = "us-central1"
}
```

## Quick Start Example

```bash
# Navigate to GKE module
cd gcp/compute/gke

# Copy example config
cp examples/basic/config.yaml my-cluster.yaml

# Edit with your values
vim my-cluster.yaml

# Create main.tf
cat > main.tf << 'EOF'
module "gke" {
  source = "../../../gcp/compute/gke"
  config_file = "my-cluster.yaml"
}

output "cluster_endpoint" {
  value = module.gke.cluster_endpoint
}
EOF

# Deploy
tofu init
tofu apply
```

## Private Service Connect

All network-aware modules (GKE, Cloud Run, Cloud Functions) support Private Service Connect to keep traffic within the VPC. The VPC module includes pre-configured Private Google Access for:

- Cloud Storage
- BigQuery
- Container Registry / Artifact Registry
- Secret Manager
- Cloud KMS
- Cloud SQL

## Cost Optimization

GCP modules include cost-aware defaults:

- **GCE** — E2 machine types for general-purpose workloads
- **GKE** — Autopilot mode available for hands-off cluster management
- **Cloud Storage** — Nearline and Coldline classes with lifecycle management
- **Cloud SQL** — Shared-core instances for dev/test workloads
- **Cloud Run** — Minimum instances set to 0 for true pay-per-use

## Compliance

All modules align with:

- **CIS Google Cloud Platform Foundation Benchmark v2.0.0**
- **Google Cloud Architecture Framework** (Security, Reliability, Performance pillars)
- **NIST 800-53** controls (encryption, audit logging, least privilege)
- **ISO 27001** and **SOC 2** requirements

## Support

For GCP-specific issues:
1. Check the module's README for troubleshooting guidance
2. Review Google provider documentation for resource-specific constraints
3. Open an issue with `[GCP]` prefix in the title

## Additional Resources

- [Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Google Cloud Architecture Framework](https://cloud.google.com/architecture/framework)
- [CIS GCP Foundations Benchmark](https://www.cisecurity.org/benchmark/google_cloud_computing_platform)
