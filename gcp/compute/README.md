# GCP Compute Modules

Production-hardened compute resources for GCP with service accounts, disk encryption, and auto-scaling.

## Modules

### [GCE](./gce/README.md)
Compute Engine instances and Managed Instance Groups with:
- Service account with least privilege
- Disk encryption with CMEK
- Shielded VM (Secure Boot, vTPM, integrity monitoring)
- OS Login
- Cloud Monitoring agent
- Auto-scaling with CPU/load balancing metrics

### [GKE](./gke/README.md)
Managed Kubernetes clusters with:
- Workload Identity
- Private cluster option
- Shielded GKE nodes
- Node auto-provisioning
- Binary Authorization
- Cloud Logging and Monitoring integration

### [Cloud Run](./cloud-run/README.md)
Serverless containers with:
- VPC connector for private access
- IAM authentication
- Concurrency limits
- CPU allocation (always or request-based)
- Cloud SQL connections
- Custom domains with SSL

### [Cloud Functions](./functions/README.md)
Event-driven functions with:
- VPC connector
- Service account
- Cloud Trace integration
- Secret Manager integration
- Event triggers (Pub/Sub, Storage, HTTP)
- 2nd gen runtime

## Common Configuration

All compute modules share these YAML fields:

```yaml
meta:
  environment: production
  region: us-central1
  name: my-compute
  team: platform
  cost_center: eng-001

gcp:
  project_id: my-gcp-project

compute:
  machine_type: n2-standard-4      # GCE, varies by module
  min_replicas: 2                  # Auto-scaling minimum
  max_replicas: 10                 # Auto-scaling maximum

networking:
  network: projects/my-project/global/networks/vpc-prod
  subnetwork: projects/my-project/regions/us-central1/subnetworks/subnet-compute
  
monitoring:
  enable_cloud_logging: true
  enable_cloud_monitoring: true

security:
  encryption_enabled: true
  service_account_email: "..."
  public_access: false
  shielded_vm: true                # GCE, GKE

labels:
  custom_label: value
```

## Security Defaults

| Control | GCE | GKE | Cloud Run | Functions |
|---------|-----|-----|-----------|-----------|
| **Service Account** | ✓ | ✓ | ✓ | ✓ |
| **Disk Encryption** | ✓ | ✓ | N/A | N/A |
| **Shielded VM** | ✓ | ✓ | N/A | N/A |
| **VPC Integration** | ✓ | ✓ | ✓ | ✓ |
| **IAM Auth** | ✓ | ✓ | ✓ | ✓ |
| **Cloud Logging** | ✓ | ✓ | ✓ | ✓ |

## Performance Defaults

- **Custom Machine Types** — Optimize CPU/memory ratio for workload
- **Local SSD** — Available for high-IOPS workloads
- **Placement Policies** — Compact placement for low-latency communication
- **Minimum Instances** — Available for Cloud Run to reduce cold starts
- **Preemptible VMs** — Available for fault-tolerant batch workloads

## Quick Start

```bash
# Example: Deploy a GKE cluster
cd gcp/compute/gke
cp examples/basic/config.yaml my-cluster.yaml

# Edit config
vim my-cluster.yaml

# Deploy
cat > main.tf << 'EOF'
module "gke" {
  source = "../../../gcp/compute/gke"
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
output "resource_self_link" { }
output "service_account_email" { }  # If applicable
output "connection_endpoint" { }    # GKE, Cloud Run
```
