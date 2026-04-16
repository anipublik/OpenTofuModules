# AWS Compute Modules

Production-hardened compute resources for AWS with auto-scaling, enhanced networking, and IMDSv2 enforcement.

## Modules

### [EC2](./ec2/README.md)
Standalone EC2 instances and Auto Scaling Groups with:
- IMDSv2 enforcement
- EBS encryption with KMS
- Enhanced networking (ENA)
- Systems Manager Session Manager access
- CloudWatch detailed monitoring
- Auto Scaling with target tracking policies

### [EKS](./eks/README.md)
Managed Kubernetes clusters with:
- Encrypted secrets using AWS KMS
- Private API endpoint option
- IRSA (IAM Roles for Service Accounts)
- Managed node groups with launch templates
- Control plane logging to CloudWatch
- VPC CNI with custom networking

### [Lambda](./lambda/README.md)
Serverless functions with:
- VPC integration with private subnets
- X-Ray tracing enabled
- Environment variable encryption
- Dead letter queue configuration
- Reserved concurrency limits
- ARM64 architecture support

### [ECS](./ecs/README.md)
Fargate tasks and services with:
- Task execution role with least privilege
- CloudWatch Logs integration
- Service discovery via Cloud Map
- Application Load Balancer integration
- Auto-scaling based on CPU/memory
- Secrets injection from Secrets Manager

## Common Configuration

All compute modules share these YAML fields:

```yaml
meta:
  environment: production
  region: us-east-1
  name: my-compute
  team: platform
  cost_center: eng-001

compute:
  instance_type: t3.medium        # EC2, varies by module
  min_size: 2                     # Auto-scaling minimum
  max_size: 10                    # Auto-scaling maximum
  desired_size: 3                 # Initial capacity

networking:
  vpc_id: vpc-12345678
  subnet_ids:
    - subnet-11111111
    - subnet-22222222
  security_group_ids:
    - sg-33333333

monitoring:
  detailed_monitoring: true
  log_retention_days: 30
  xray_tracing: true              # Lambda, ECS

security:
  encryption_enabled: true
  imdsv2_required: true           # EC2 only
  public_access: false

tags:
  custom_tag: value
```

## Security Defaults

| Control | EC2 | EKS | Lambda | ECS |
|---------|-----|-----|--------|-----|
| **IMDSv2** | ✓ | ✓ | N/A | N/A |
| **EBS Encryption** | ✓ | ✓ | N/A | N/A |
| **Secrets Encryption** | N/A | ✓ | ✓ | ✓ |
| **VPC Integration** | ✓ | ✓ | ✓ | ✓ |
| **IAM Least Privilege** | ✓ | ✓ | ✓ | ✓ |
| **CloudWatch Logs** | ✓ | ✓ | ✓ | ✓ |

## Performance Defaults

- **Enhanced Networking** — ENA enabled on all EC2 instances
- **Placement Groups** — Available as opt-in for low-latency workloads
- **Graviton** — ARM64 instances available for 40% better price-performance
- **Provisioned Concurrency** — Available for Lambda to eliminate cold starts
- **Fargate Spot** — Available for ECS fault-tolerant workloads

## Quick Start

```bash
# Example: Deploy an EKS cluster
cd aws/compute/eks
cp examples/basic/config.yaml my-cluster.yaml

# Edit config
vim my-cluster.yaml

# Deploy
cat > main.tf << 'EOF'
module "eks" {
  source = "../../../aws/compute/eks"
  config_file = "my-cluster.yaml"
}
EOF

tofu init && tofu apply
```

## Outputs

All compute modules output:

```hcl
output "resource_id" { }
output "resource_arn" { }
output "resource_name" { }
output "security_group_id" { }      # If applicable
output "iam_role_arn" { }           # If applicable
output "connection_endpoint" { }    # EKS, ECS
```
