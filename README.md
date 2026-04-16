# OpenTofu Cloud Modules Library

⚠️ **DEVELOPMENT STATUS**: This library is under active development and has not been tested in production environments. Use at your own risk.

Production-hardened, security-first, YAML-driven OpenTofu modules for AWS, Azure, GCP, and Datadog.

## Philosophy

Every module in this library is built on three principles:

1. **Security by default** — Encryption, least privilege, network isolation, and audit logging are non-negotiable and enabled out of the box
2. **YAML-driven configuration** — No HCL fluency required; all inputs surface through structured YAML files
3. **Production-ready from day one** — Multi-AZ, backups, monitoring, and compliance controls baked in, not bolted on

## Quick Start

```bash
# Clone the repository
git clone https://github.com/your-org/opentofu-modules.git
cd opentofu-modules

# Navigate to a module (example: AWS EKS)
cd aws/compute/eks

# Copy and customize the example config
cp examples/basic/config.yaml my-cluster.yaml
# Edit my-cluster.yaml with your values

# Create a minimal main.tf
cat > main.tf << 'EOF'
module "eks" {
  source = "./aws/compute/eks"
  config_file = "my-cluster.yaml"
}
EOF

# Initialize and apply
tofu init
tofu plan
tofu apply
```

## Repository Structure

```
opentofu-modules/
├── aws/              # AWS modules (EC2, EKS, RDS, S3, Lambda, etc.)
├── azure/            # Azure modules (VM, AKS, SQL, Blob, Functions, etc.)
├── gcp/              # GCP modules (GCE, GKE, Cloud SQL, GCS, Cloud Run, etc.)
├── datadog/          # Datadog modules (Monitors, Dashboards, SLOs, Synthetics, etc.)
├── shared/           # Cross-provider utilities (tagging, naming, validation)
├── examples/         # End-to-end examples per provider
└── policy/           # OPA policies for validation
```

## Provider Coverage

### [AWS](./aws/README.md)
Compute (EC2, EKS, Lambda, ECS) • Network (VPC, ALB, Route 53) • Storage (S3, RDS, DynamoDB) • Security (KMS, Secrets Manager, IAM) • Messaging (SQS, SNS) • Observability (CloudWatch, CloudTrail)

### [Azure](./azure/README.md)
Compute (VM, AKS, Functions, Container Apps) • Network (VNet, NSG, App Gateway) • Storage (Blob, SQL, CosmosDB) • Security (Key Vault, Managed Identity) • Messaging (Service Bus, Event Grid) • Observability (Log Analytics, Monitor)

### [GCP](./gcp/README.md)
Compute (GCE, GKE, Cloud Run, Functions) • Network (VPC, Firewall, Load Balancing) • Storage (GCS, Cloud SQL, Spanner) • Security (KMS, Secret Manager, IAM) • Messaging (Pub/Sub) • Observability (Cloud Logging, Monitoring)

### [Datadog](./datadog/README.md)
Monitors (APM, Infrastructure, Logs, Custom, Composite) • Dashboards (Timeboard, Screenboard) • Synthetics (API Test, Browser Test) • Logs (Pipeline, Index, Archive) • Integrations (AWS, Azure, GCP, Slack, PagerDuty) • SLO (Metric, Monitor)

## Security Pillars

Every module enforces these security controls by default:

| Control | Implementation |
|---------|---------------|
| **Encryption at rest** | Provider-managed or customer-managed keys, rotation enabled |
| **Encryption in transit** | TLS enforced on all network communication |
| **Least privilege IAM** | No wildcard actions or resources in default policies |
| **Network isolation** | No public exposure by default; explicit opt-in required |
| **Secrets management** | Supports AWS-managed secrets (RDS), references to secret managers. **Note:** Some modules may store secrets in state if not configured properly. |
| **Audit logging** | CloudTrail, Azure Monitor, Cloud Audit Logs enabled with 90-day minimum retention |
| **Compliance** | CIS benchmark alignment (IMDSv2, public bucket blocks, HTTPS-only, uniform access) |

## YAML Configuration Pattern

All modules use a consistent YAML schema for shared attributes:

```yaml
meta:
  environment: production    # Required — drives naming and tagging
  region: us-east-1         # Required
  name: my-resource         # Required
  team: platform            # Required
  cost_center: eng-001      # Required

tags:
  custom_tag: value         # Optional — merged with required tags

security:
  encryption_enabled: true          # Default true
  public_access: false              # Default false
  deletion_protection: true         # Default true
  audit_logging: true               # Default true

reliability:
  multi_az: true                    # Default true
  backup_retention_days: 7          # Default 7
  point_in_time_recovery: true      # Default true
```

Resource-specific configuration sits under a top-level key (e.g., `cluster:`, `bucket:`, `instance:`).

## Module Anatomy

Every module follows this structure:

```
module-name/
├── main.tf          # Resource definitions
├── variables.tf     # Single config_file variable
├── outputs.tf       # Standardized outputs (ID, ARN, name, region)
├── versions.tf      # Provider and OpenTofu version constraints
├── locals.tf        # YAML decode and derived values
├── iam.tf           # IAM resources (if applicable)
├── security.tf      # Security groups / firewall rules
├── README.md        # Usage guide, YAML schema, examples
└── examples/
    └── basic/
        ├── main.tf
        └── config.yaml
```

## Outputs Convention

Every module outputs a consistent set of fields:

```hcl
output "resource_id" { }
output "resource_arn" { }      # Or equivalent (Azure resource ID, GCP self_link)
output "resource_name" { }
output "resource_region" { }
output "connection_endpoint" { }  # If applicable (DB, cache, LB)
```

## Quality Gates

Every pull request runs the following checks via `.github/workflows/ci.yml`:

- **Format check** — `tofu fmt -check -recursive`
- **Static analysis** — `tflint` with AWS/Azure/GCP rulesets per provider directory
- **Security scanning** — `checkov` and `trivy` (fails on CRITICAL/HIGH)
- **Policy validation** — OPA unit tests (`opa test policy`) and plan-time enforcement against representative module plans
- **Documentation** — every module must have a `README.md`; `terraform-docs --output-check` verifies generated sections are in sync
- **Example validation** — every module's `examples/basic/` is loaded with `tofu init -backend=false && tofu validate`; a representative subset additionally runs `tofu plan`

**Note:** This library is currently in development. Modules have not been tested in production environments.

## Versioning

Modules follow semantic versioning with independent Git tags per module:

```
aws/eks/v1.2.0
azure/aks/v2.0.1
gcp/gke/v1.5.3
```

- **Major** — Breaking YAML schema changes
- **Minor** — New optional YAML fields
- **Patch** — Bug fixes and security patches

## Requirements

- OpenTofu `>= 1.7.0`
- Provider versions pinned with `~>` constraints in each module's `versions.tf`

## Contributing

1. Fork the repository
2. Use the `_template/` directory to bootstrap new modules
3. Ensure all quality gates pass in CI
4. Include at least one working example with `config.yaml`
5. Security defaults cannot be weakened — only strengthened or made configurable with secure defaults

## Support

- **Issues** — Report bugs or request features via GitHub Issues
- **Discussions** — Ask questions or share patterns in GitHub Discussions
- **Security** — Report vulnerabilities privately via security@example.com

## License

Apache 2.0

---

**Built with ❤️ for practitioners who value security, reliability, and operational excellence.**
