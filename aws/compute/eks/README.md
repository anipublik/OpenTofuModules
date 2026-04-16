# AWS EKS Module

Production-hardened Amazon EKS cluster with encrypted secrets, private endpoints, and IRSA.

## Features

- **Encrypted Secrets** — Kubernetes secrets encrypted at rest using AWS KMS
- **Private API Endpoint** — Optional private-only cluster endpoint
- **IRSA** — IAM Roles for Service Accounts for pod-level permissions
- **Managed Node Groups** — Launch templates with IMDSv2 and EBS encryption
- **Control Plane Logging** — All log types enabled to CloudWatch
- **VPC CNI** — Custom networking support for IP conservation
- **Add-ons** — CoreDNS, kube-proxy, VPC CNI managed by AWS
- **Security Groups** — Cluster and node security groups with least-privilege rules

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-east-1
  name: platform-eks
  team: platform
  cost_center: eng-001

cluster:
  kubernetes_version: "1.30"
  endpoint_private_access: true
  endpoint_public_access: false      # Set true for public access
  public_access_cidrs:               # If public access enabled
    - "203.0.113.0/24"
  
  encryption:
    enabled: true
    kms_key_id: "arn:aws:kms:us-east-1:123456789012:key/..."  # Optional
  
  logging:
    enabled: true
    types:
      - api
      - audit
      - authenticator
      - controllerManager
      - scheduler

networking:
  vpc_id: vpc-12345678
  subnet_ids:
    - subnet-11111111              # Private subnet AZ1
    - subnet-22222222              # Private subnet AZ2
    - subnet-33333333              # Private subnet AZ3
  
  cluster_security_group_ids:      # Optional additional SGs
    - sg-44444444

node_groups:
  - name: general
    instance_types:
      - m5.xlarge
      - m5a.xlarge
    capacity_type: ON_DEMAND         # or SPOT
    min_size: 2
    max_size: 10
    desired_size: 3
    disk_size: 100                   # GB
    disk_encrypted: true
    labels:
      workload: general
    taints: []
    
  - name: compute
    instance_types:
      - c5.2xlarge
    capacity_type: ON_DEMAND
    min_size: 0
    max_size: 20
    desired_size: 0
    disk_size: 100
    labels:
      workload: compute-intensive
    taints:
      - key: workload
        value: compute
        effect: NoSchedule

addons:
  vpc_cni:
    version: "v1.18.0-eksbuild.1"
    resolve_conflicts: OVERWRITE
  coredns:
    version: "v1.11.1-eksbuild.4"
  kube_proxy:
    version: "v1.30.0-eksbuild.3"

security:
  encryption_enabled: true
  public_access: false
  deletion_protection: true
  audit_logging: true
  imdsv2_required: true              # Enforced on node groups

tags:
  project: platform
  compliance: pci-dss
```

## Usage

```hcl
module "eks" {
  source = "./aws/compute/eks"
  config_file = "eks-cluster.yaml"
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "cluster_certificate_authority" {
  value = module.eks.cluster_certificate_authority
  sensitive = true
}

output "cluster_oidc_issuer_url" {
  value = module.eks.cluster_oidc_issuer_url
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `cluster_id` | EKS cluster name |
| `cluster_arn` | EKS cluster ARN |
| `cluster_endpoint` | Kubernetes API endpoint |
| `cluster_certificate_authority` | Base64-encoded CA certificate |
| `cluster_security_group_id` | Cluster security group ID |
| `cluster_oidc_issuer_url` | OIDC provider URL for IRSA |
| `node_group_ids` | Map of node group names to IDs |
| `node_security_group_id` | Node security group ID |
| `cluster_iam_role_arn` | Cluster IAM role ARN |

## IRSA Setup

The module creates an OIDC provider for IRSA. To create a service account IAM role:

```hcl
module "irsa_role" {
  source = "./aws/security/iam-role"
  
  config_file = "irsa-role.yaml"
}
```

Example `irsa-role.yaml`:

```yaml
meta:
  environment: production
  region: us-east-1
  name: app-service-account
  team: platform
  cost_center: eng-001

role:
  assume_role_policy:
    type: federated
    federated_principal: "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE"
    conditions:
      - test: StringEquals
        variable: "oidc.eks.us-east-1.amazonaws.com/id/EXAMPLED539D4633E53DE1B71EXAMPLE:sub"
        values:
          - "system:serviceaccount:default:my-service-account"
  
  policies:
    - "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
```

## kubectl Configuration

```bash
aws eks update-kubeconfig \
  --region us-east-1 \
  --name platform-eks-production \
  --alias platform-eks
```

## Security Considerations

- **Private Endpoint** — Set `endpoint_public_access: false` for maximum security
- **Public Access CIDRs** — If public access required, restrict to known IPs
- **Node IAM Roles** — Use IRSA instead of node IAM roles for pod permissions
- **Security Groups** — Cluster and node SGs follow least-privilege rules
- **Secrets Encryption** — Always use KMS encryption for secrets at rest
- **IMDSv2** — Enforced on all node groups to prevent SSRF attacks

## Cost Optimization

- **Spot Instances** — Use `capacity_type: SPOT` for fault-tolerant workloads
- **Graviton** — Use `m6g`, `c6g`, `r6g` instance types for 20% cost savings
- **Cluster Autoscaler** — Install to scale node groups based on pod demand
- **Fargate** — Consider EKS on Fargate for serverless node management

## Troubleshooting

**Nodes not joining cluster:**
- Verify subnet route tables have route to NAT gateway or VPC endpoints
- Check node security group allows traffic from cluster security group
- Verify IAM role has `AmazonEKSWorkerNodePolicy` attached

**Pods can't pull images:**
- Ensure VPC has ECR VPC endpoints or NAT gateway
- Verify node IAM role has `AmazonEC2ContainerRegistryReadOnly` policy

**IRSA not working:**
- Verify OIDC provider is created and matches cluster OIDC issuer
- Check service account annotation: `eks.amazonaws.com/role-arn`
- Verify IAM role trust policy includes correct OIDC provider and namespace

## Additional Resources

- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [EKS User Guide](https://docs.aws.amazon.com/eks/latest/userguide/)
- [IRSA Documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
