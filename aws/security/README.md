# AWS Security Modules

Production-hardened security resources for AWS with least-privilege policies, encryption, and audit logging.

## Modules

### [KMS](./kms/README.md)
Customer-managed encryption keys with:
- Automatic key rotation enabled
- Key policies with least privilege
- Multi-region keys available
- CloudTrail logging of key usage
- Deletion protection (pending deletion window)
- Alias management

### [Secrets Manager](./secrets-manager/README.md)
Secret storage and rotation with:
- Encryption with KMS
- Automatic rotation with Lambda
- Version management
- Resource-based policies
- Cross-account access
- Replica secrets for multi-region

### [IAM Role](./iam-role/README.md)
Service roles with:
- Scoped trust policies
- Least-privilege permissions
- Managed policy attachments
- Inline policies
- Permission boundaries
- Session duration limits

### [IAM Policy](./iam-policy/README.md)
Policy documents with:
- No wildcard actions by default
- No wildcard resources by default
- Condition-based access
- Policy validation
- Version management

### [WAF](./waf/README.md)
Web application firewall with:
- Managed rule groups (OWASP, Bot Control)
- Custom rules
- Rate limiting
- Geo-blocking
- IP reputation lists
- CloudWatch metrics

## Common Configuration

All security modules share these YAML fields:

```yaml
meta:
  environment: production
  region: us-east-1
  name: my-security
  team: platform
  cost_center: eng-001

security:
  encryption_enabled: true
  deletion_protection: true
  audit_logging: true
  rotation_enabled: true            # Secrets Manager, KMS

tags:
  custom_tag: value
```

## Security Defaults

| Control | KMS | Secrets Manager | IAM Role | IAM Policy | WAF |
|---------|-----|-----------------|----------|------------|-----|
| **Encryption** | N/A | ✓ | N/A | N/A | N/A |
| **Rotation** | ✓ | ✓ | N/A | N/A | N/A |
| **Audit Logging** | ✓ | ✓ | ✓ | ✓ | ✓ |
| **Least Privilege** | ✓ | ✓ | ✓ | ✓ | N/A |
| **Deletion Protection** | ✓ | ✓ | N/A | N/A | N/A |

## IAM Best Practices

All IAM modules enforce:
- No wildcard (`*`) actions in default policies
- No wildcard (`*`) resources in default policies
- Condition keys for additional constraints
- MFA required for sensitive operations
- Session duration limits
- Permission boundaries for delegated admin

## Quick Start

```bash
# Example: Create a KMS key
cd aws/security/kms
cp examples/basic/config.yaml my-key.yaml

# Edit config
vim my-key.yaml

# Deploy
cat > main.tf << 'EOF'
module "kms" {
  source = "../../../aws/security/kms"
  config_file = "my-key.yaml"
}
EOF

tofu init && tofu apply
```

## Outputs

All security modules output:

```hcl
output "resource_id" { }
output "resource_arn" { }
output "resource_name" { }
output "key_id" { }                 # KMS
output "secret_arn" { }             # Secrets Manager
output "role_arn" { }               # IAM Role
output "policy_arn" { }             # IAM Policy
output "web_acl_arn" { }            # WAF
```
