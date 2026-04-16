# GCP VPC Module

Production-hardened Google Cloud VPC with private Google access, flow logs, and Cloud NAT.

## Features

- **Custom Subnets** — No auto-created subnets, full control over IP ranges
- **Private Google Access** — Access Google APIs without public IPs
- **Flow Logs** — VPC flow logs enabled on all subnets
- **Secondary IP Ranges** — Support for GKE pod/service IP ranges
- **Cloud NAT** — Managed NAT gateway for private instance internet access
- **Default Deny** — Deny-all ingress firewall rule for security
- **Internal Communication** — Allow-internal firewall for subnet-to-subnet traffic
- **Regional or Global Routing** — Choose routing mode based on needs

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: platform-vpc
  team: platform
  cost_center: eng-001

gcp:
  project_id: my-gcp-project

network:
  routing_mode: REGIONAL              # or GLOBAL
  
  subnets:
    - name: private-us-central1-a
      ip_cidr_range: 10.0.0.0/24
      region: us-central1
      private_google_access: true
      secondary_ip_ranges:
        - range_name: pods
          ip_cidr_range: 10.1.0.0/16
        - range_name: services
          ip_cidr_range: 10.2.0.0/20
    
    - name: private-us-central1-b
      ip_cidr_range: 10.0.1.0/24
      region: us-central1
      private_google_access: true
    
    - name: private-us-east1-a
      ip_cidr_range: 10.0.2.0/24
      region: us-east1
      private_google_access: true

tags:
  project: platform
  compliance: pci-dss
```

## Usage

```hcl
module "vpc" {
  source = "./gcp/network/vpc"
  config_file = "vpc.yaml"
}

output "network_id" {
  value = module.vpc.network_id
}

output "subnet_ids" {
  value = module.vpc.subnet_ids
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `network_id` | VPC network ID |
| `network_name` | VPC network name |
| `network_self_link` | VPC network self link |
| `subnet_ids` | Map of subnet names to IDs |
| `subnet_self_links` | Map of subnet names to self links |
| `router_id` | Cloud Router ID |
| `nat_id` | Cloud NAT ID |

## GKE Integration

For GKE clusters, configure secondary IP ranges for pods and services:

```yaml
network:
  subnets:
    - name: gke-subnet
      ip_cidr_range: 10.0.0.0/24
      region: us-central1
      private_google_access: true
      secondary_ip_ranges:
        - range_name: gke-pods
          ip_cidr_range: 10.100.0.0/16    # /16 for large clusters
        - range_name: gke-services
          ip_cidr_range: 10.200.0.0/20    # /20 for services
```

Then reference in GKE module:

```yaml
networking:
  network: projects/my-project/global/networks/platform-vpc-production
  subnetwork: projects/my-project/regions/us-central1/subnetworks/gke-subnet
  pod_ip_range_name: gke-pods
  service_ip_range_name: gke-services
```

## Security Considerations

- **Private Google Access** — Enabled by default for accessing Google APIs without public IPs
- **Flow Logs** — All subnets have flow logs enabled for security monitoring
- **Default Deny** — Deny-all ingress rule prevents unauthorized access
- **Cloud NAT** — Provides internet access without exposing instances
- **No Auto Subnets** — Manual subnet creation prevents unintended exposure

## Cost Optimization

- **Regional Routing** — Use `REGIONAL` routing mode to avoid cross-region charges
- **Cloud NAT** — Charged per gateway and data processed, consider shared NAT for multiple subnets
- **Flow Logs** — Sampling at 50% reduces storage costs while maintaining visibility
- **IP Ranges** — Plan CIDR ranges carefully to avoid wasting IP space

## Troubleshooting

**Instances can't reach internet:**
- Verify Cloud NAT is created and associated with router
- Check subnet has route to default internet gateway (0.0.0.0/0)
- Ensure instances don't have external IPs (NAT handles egress)

**Can't access Google APIs:**
- Verify `private_google_access: true` on subnet
- Check firewall rules allow egress to Google API ranges
- Ensure DNS resolves to private Google access IPs

**GKE pods can't communicate:**
- Verify secondary IP ranges are configured on subnet
- Check allow-internal firewall includes secondary ranges
- Ensure GKE cluster references correct secondary range names

## Additional Resources

- [VPC Documentation](https://cloud.google.com/vpc/docs)
- [Cloud NAT Documentation](https://cloud.google.com/nat/docs)
- [VPC Flow Logs](https://cloud.google.com/vpc/docs/flow-logs)
- [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access)
