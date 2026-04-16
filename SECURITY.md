# Security Policy

## Supported Versions

This library is under active development. Only the `main` branch is currently supported. Once v1.0.0 is tagged, supported versions will be listed here.

## Reporting a Vulnerability

If you discover a security vulnerability in any module, **please do not open a public GitHub issue**.

Instead, email `security@example.com` with:

1. A description of the vulnerability
2. Steps to reproduce
3. The module(s) affected
4. Any suggested remediation

We aim to:

- Acknowledge receipt within **3 business days**
- Provide an initial assessment within **10 business days**
- Ship a fix (or document a mitigation) within **90 days**

Coordinated disclosure is appreciated; please allow us up to 90 days before public disclosure.

## Known Security Exceptions

The following checks are intentionally soft-failed or skipped in `.checkov.yml` with justification. These are tracked here so they don't silently accumulate.

| Check ID | Scope | Reason |
|---|---|---|
| `CKV_AWS_23` | AWS security group rules | Descriptions are auto-generated from YAML input; per-rule descriptions are not always meaningful |
| `CKV_AWS_24` | AWS security group ingress | Ingress CIDR control is intentionally user-configurable via the YAML config |
| `CKV_AZURE_35` | Azure NSG rules | Same rationale as `CKV_AWS_23` |
| `CKV_GCP_6` | GCE block project-wide SSH keys | Configurable per deployment |
| `CKV_AWS_126` | RDS IAM authentication | Soft-fail: RDS IAM auth is recommended but not mandated |
| `CKV_AZURE_113` | Azure SQL AD authentication | Soft-fail: Azure AD auth is recommended but not mandated |

## Secure Defaults Enforced by Every Module

- Encryption at rest (customer-managed or provider-managed keys)
- TLS in transit
- Least-privilege IAM policies (no wildcard actions or resources)
- No public network exposure by default
- Audit logging enabled with ≥90-day retention
- Deletion protection enabled in production environments
- Raw secrets rejected in production configs (see per-module guards in RDS, ElastiCache, Cloud SQL, Azure SQL, and Datadog integrations)

## Reviewing Security-Sensitive Changes

Pull requests that modify any of the following files require explicit review:

- `shared/validation/**`
- `policy/**`
- `.checkov.yml`
- `.tflint.hcl`
- `SECURITY.md`
- Any `iam.tf` or `security.tf` under a module
