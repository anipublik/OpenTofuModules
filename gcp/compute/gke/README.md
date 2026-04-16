# GCP GKE Module

Production-hardened Google Kubernetes Engine cluster with Workload Identity, private clusters, and Binary Authorization.

## Features

- **Workload Identity** — Pod-level service account authentication
- **Private Cluster** — Private nodes and optional private control plane
- **Shielded GKE Nodes** — Secure Boot and integrity monitoring
- **Node Auto-Provisioning** — Automatic node pool creation based on workload
- **Binary Authorization** — Enforce signed container images
- **Cloud Logging & Monitoring** — Integrated observability
- **Release Channels** — Automatic version management
- **Network Policy** — Calico network policy enforcement

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: platform-gke
  team: platform
  cost_center: eng-001

gcp:
  project_id: my-gcp-project

cluster:
  kubernetes_version: "1.29"         # Or use release_channel
  release_channel: REGULAR           # RAPID, REGULAR, STABLE, or null for static version
  
  network_config:
    network: projects/my-project/global/networks/vpc-prod
    subnetwork: projects/my-project/regions/us-central1/subnetworks/subnet-gke
    
    # IP ranges
    cluster_ipv4_cidr_block: 10.4.0.0/14
    services_ipv4_cidr_block: 10.8.0.0/20
    
    # Private cluster
    enable_private_nodes: true
    enable_private_endpoint: false   # Set true for fully private
    master_ipv4_cidr_block: 172.16.0.0/28
    master_authorized_networks:
      - cidr_block: 10.0.0.0/8
        display_name: internal
  
  workload_identity:
    enabled: true
  
  addons:
    http_load_balancing: true
    horizontal_pod_autoscaling: true
    network_policy_config: true
    gce_persistent_disk_csi_driver: true
    gcp_filestore_csi_driver: false
  
  logging_config:
    enable_components:
      - SYSTEM_COMPONENTS
      - WORKLOADS
  
  monitoring_config:
    enable_components:
      - SYSTEM_COMPONENTS
      - WORKLOADS
    managed_prometheus: true
  
  binary_authorization:
    evaluation_mode: PROJECT_SINGLETON_POLICY_ENFORCE  # or DISABLED
  
  maintenance_policy:
    recurring_window:
      start_time: "2024-01-01T00:00:00Z"
      end_time: "2024-01-01T04:00:00Z"
      recurrence: "FREQ=WEEKLY;BYDAY=SA"

node_pools:
  - name: system
    initial_node_count: 1
    
    autoscaling:
      min_node_count: 1
      max_node_count: 5
      location_policy: BALANCED
    
    node_config:
      machine_type: n2-standard-4
      disk_size_gb: 100
      disk_type: pd-standard
      image_type: COS_CONTAINERD
      
      oauth_scopes:
        - https://www.googleapis.com/auth/cloud-platform
      
      service_account: "gke-nodes@my-project.iam.gserviceaccount.com"
      
      shielded_instance_config:
        enable_secure_boot: true
        enable_integrity_monitoring: true
      
      workload_metadata_config:
        mode: GKE_METADATA
      
      labels:
        workload: system
      
      taints: []
    
    management:
      auto_repair: true
      auto_upgrade: true
  
  - name: compute
    initial_node_count: 0
    
    autoscaling:
      min_node_count: 0
      max_node_count: 20
    
    node_config:
      machine_type: n2-standard-8
      disk_size_gb: 200
      preemptible: false
      spot: false                    # Set true for Spot VMs
      
      labels:
        workload: compute-intensive
      
      taints:
        - key: workload
          value: compute
          effect: NO_SCHEDULE

security:
  encryption_enabled: true
  public_access: false
  deletion_protection: true
  audit_logging: true

labels:
  project: platform
  compliance: soc2
```

## Usage

```hcl
module "gke" {
  source = "./gcp/compute/gke"
  config_file = "gke-cluster.yaml"
}

output "cluster_endpoint" {
  value = module.gke.cluster_endpoint
}

output "cluster_ca_certificate" {
  value = module.gke.cluster_ca_certificate
  sensitive = true
}

output "cluster_name" {
  value = module.gke.cluster_name
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `cluster_id` | GKE cluster ID |
| `cluster_name` | GKE cluster name |
| `cluster_endpoint` | Kubernetes API endpoint |
| `cluster_ca_certificate` | Base64-encoded CA certificate |
| `cluster_self_link` | GKE cluster self link |
| `workload_identity_pool` | Workload Identity pool for IRSA-style auth |
| `node_pools` | Map of node pool names to self links |
| `service_account` | Node service account email |

## Workload Identity Setup

The module enables Workload Identity. To bind a Kubernetes service account to a GCP service account:

```bash
# Create GCP service account
gcloud iam service-accounts create app-sa \
  --project=my-gcp-project

# Grant permissions
gcloud projects add-iam-policy-binding my-gcp-project \
  --member="serviceAccount:app-sa@my-gcp-project.iam.gserviceaccount.com" \
  --role="roles/storage.objectViewer"

# Bind to Kubernetes service account
gcloud iam service-accounts add-iam-policy-binding \
  app-sa@my-gcp-project.iam.gserviceaccount.com \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:my-gcp-project.svc.id.goog[default/my-ksa]"
```

Kubernetes service account:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: my-ksa
  namespace: default
  annotations:
    iam.gke.io/gcp-service-account: app-sa@my-gcp-project.iam.gserviceaccount.com
```

## kubectl Configuration

```bash
gcloud container clusters get-credentials platform-gke-production \
  --region us-central1 \
  --project my-gcp-project
```

## Security Considerations

- **Private Nodes** — Always set `enable_private_nodes: true`
- **Private Endpoint** — Set `enable_private_endpoint: true` for maximum security
- **Master Authorized Networks** — Restrict API access to known CIDR blocks
- **Workload Identity** — Use instead of node service account for pod permissions
- **Binary Authorization** — Enforce signed images in production
- **Shielded Nodes** — Enable Secure Boot and integrity monitoring
- **Network Policy** — Enable Calico for pod-to-pod security

## Cost Optimization

- **Autopilot** — Consider GKE Autopilot for hands-off management (separate module)
- **Spot VMs** — Use `spot: true` for fault-tolerant workloads (up to 91% savings)
- **Preemptible VMs** — Use `preemptible: true` for batch workloads (up to 80% savings)
- **Node Auto-Provisioning** — Let GKE create optimal node pools automatically
- **Cluster Autoscaler** — Automatically enabled with autoscaling config
- **E2 Machine Types** — Use E2 instances for cost-effective general-purpose workloads

## Troubleshooting

**Nodes not ready:**
- Check subnet has sufficient IP addresses for pods and services
- Verify firewall rules allow traffic from control plane to nodes
- Check service account has required permissions

**Can't access API server:**
- For private endpoint, ensure you're on VPC or using Cloud VPN/Interconnect
- Verify your IP is in master_authorized_networks
- Check IAM permissions (container.clusters.get)

**Workload Identity not working:**
- Verify Workload Identity is enabled on cluster and node pool
- Check Kubernetes service account annotation matches GCP service account
- Verify IAM binding for workloadIdentityUser role

## Additional Resources

- [GKE Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices)
- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
- [Binary Authorization](https://cloud.google.com/binary-authorization/docs)
