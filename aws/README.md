# AWS Modules

Production-hardened OpenTofu modules for Amazon Web Services.

## Overview

This directory contains YAML-driven modules for AWS infrastructure. Every module enforces AWS security best practices, CIS benchmark compliance, and operational excellence patterns by default.

## Module Categories

### [Compute](./compute/README.md)
Deploy EC2 instances, EKS clusters, Lambda functions, and ECS Fargate services with auto-scaling, enhanced networking, and IMDSv2 enforcement.

- **[EC2](./compute/ec2/README.md)** — Standalone instances and Auto Scaling Groups
- **[EKS](./compute/eks/README.md)** — Managed Kubernetes with encrypted secrets and private endpoints
- **[Lambda](./compute/lambda/README.md)** — Serverless functions with VPC integration and X-Ray tracing
- **[ECS](./compute/ecs/README.md)** — Fargate tasks with service discovery and load balancing

### [Network](./network/README.md)
Build VPCs, security groups, load balancers, and DNS with flow logs, PrivateLink, and least-privilege network policies.

- **[VPC](./network/vpc/README.md)** — Multi-AZ VPCs with NAT gateways and VPC endpoints
- **[Security Groups](./network/security-groups/README.md)** — Deny-by-default firewall rules
- **[ALB](./network/alb/README.md)** — Application Load Balancers with WAF integration
- **[NLB](./network/nlb/README.md)** — Network Load Balancers for TCP/UDP traffic
- **[Route 53](./network/route53/README.md)** — DNS zones with health checks and failover
- **[CloudFront](./network/cloudfront/README.md)** — CDN distributions with origin access identity

### [Storage](./storage/README.md)
Provision S3 buckets, RDS databases, DynamoDB tables, and ElastiCache clusters with encryption, backups, and multi-AZ replication.

- **[S3](./storage/s3/README.md)** — Buckets with versioning, lifecycle policies, and public access blocks
- **[RDS](./storage/rds/README.md)** — MySQL, PostgreSQL, and Aurora with automated backups
- **[DynamoDB](./storage/dynamodb/README.md)** — NoSQL tables with point-in-time recovery
- **[ElastiCache](./storage/elasticache/README.md)** — Redis and Memcached with encryption in transit

### [Security](./security/README.md)
Manage KMS keys, secrets, IAM roles, and WAF rules with least-privilege policies and audit logging.

- **[KMS](./security/kms/README.md)** — Customer-managed keys with automatic rotation
- **[Secrets Manager](./security/secrets-manager/README.md)** — Secret storage with rotation lambdas
- **[IAM Role](./security/iam-role/README.md)** — Service roles with scoped trust policies
- **[IAM Policy](./security/iam-policy/README.md)** — Least-privilege policy documents
- **[WAF](./security/waf/README.md)** — Web application firewall rules for ALB and CloudFront

### [Messaging](./messaging/README.md)
Deploy SQS queues, SNS topics, and EventBridge buses with encryption and dead-letter queues.

- **[SQS](./messaging/sqs/README.md)** — FIFO and standard queues with DLQ
- **[SNS](./messaging/sns/README.md)** — Topics with subscription filtering
- **[EventBridge](./messaging/eventbridge/README.md)** — Event buses with schema registry

### [Observability](./observability/README.md)
Configure CloudWatch log groups, alarms, and CloudTrail with retention policies and metric filters.

- **[CloudWatch Log Group](./observability/cloudwatch-log-group/README.md)** — Centralized logging with KMS encryption
- **[CloudWatch Alarm](./observability/cloudwatch-alarm/README.md)** — Metric-based alerting with SNS actions
- **[CloudTrail](./observability/cloudtrail/README.md)** — API audit logging to S3 with log file validation

## AWS-Specific Security Defaults

| Control | Implementation |
|---------|---------------|
| **IMDSv2** | Enforced on all EC2 instances and launch templates |
| **S3 Public Access** | Blocked at bucket policy level via `aws_s3_bucket_public_access_block` |
| **EBS Encryption** | Enabled by default on all volumes with KMS CMK |
| **RDS Encryption** | Storage and backups encrypted with KMS CMK |
| **VPC Flow Logs** | Enabled on all VPCs with CloudWatch Logs destination |
| **CloudTrail** | Multi-region trail with log file validation and S3 encryption |
| **Secrets Rotation** | Automatic rotation configured for RDS and Secrets Manager |
| **KMS Key Rotation** | Enabled on all customer-managed keys |

## Common YAML Schema

All AWS modules extend the base schema with AWS-specific fields:

```yaml
meta:
  environment: production
  region: us-east-1
  name: my-resource
  team: platform
  cost_center: eng-001

aws:
  account_id: "123456789012"    # Optional — used for cross-account references
  kms_key_id: "arn:aws:kms:..."  # Optional — custom KMS key for encryption

tags:
  custom_tag: value

security:
  encryption_enabled: true
  public_access: false
  deletion_protection: true
  audit_logging: true

reliability:
  multi_az: true
  backup_retention_days: 7
  point_in_time_recovery: true
```

## Provider Configuration

All modules require the AWS provider `>= 5.0`:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.7.0"
}

provider "aws" {
  region = "us-east-1"
  
  default_tags {
    tags = {
      managed_by = "opentofu"
      repository = "opentofu-modules"
    }
  }
}
```

## Quick Start Example

```bash
# Navigate to EKS module
cd aws/compute/eks

# Copy example config
cp examples/basic/config.yaml my-cluster.yaml

# Edit with your values
vim my-cluster.yaml

# Create main.tf
cat > main.tf << 'EOF'
module "eks" {
  source = "../../../aws/compute/eks"
  config_file = "my-cluster.yaml"
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
EOF

# Deploy
tofu init
tofu apply
```

## VPC Endpoints (PrivateLink)

All network-aware modules (EKS, Lambda, ECS) support VPC endpoints to keep traffic off the public internet. The VPC module includes pre-configured endpoints for:

- S3 (gateway endpoint)
- DynamoDB (gateway endpoint)
- ECR API and Docker (interface endpoints)
- Secrets Manager (interface endpoint)
- KMS (interface endpoint)
- CloudWatch Logs (interface endpoint)

## Cost Optimization

AWS modules include cost-aware defaults:

- **EC2** — Graviton instance types available as opt-in
- **RDS** — Reserved instance recommendations in outputs
- **S3** — Intelligent tiering enabled by default
- **DynamoDB** — On-demand billing mode with auto-scaling available
- **Lambda** — ARM64 architecture available for 20% cost savings

## Compliance

All modules align with:

- **CIS AWS Foundations Benchmark v1.5.0**
- **AWS Well-Architected Framework** (Security, Reliability, Performance Efficiency pillars)
- **NIST 800-53** controls (encryption, audit logging, least privilege)

## Support

For AWS-specific issues:
1. Check the module's README for troubleshooting guidance
2. Review AWS provider documentation for resource-specific constraints
3. Open an issue with `[AWS]` prefix in the title

## Additional Resources

- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [CIS AWS Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)
