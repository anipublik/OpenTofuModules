# Contributing to OpenTofu Modules

Thank you for your interest in contributing! This document provides guidelines for contributing new modules, bug fixes, and improvements.

## Code of Conduct

Be respectful, constructive, and collaborative. We're all here to build better infrastructure tooling.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/opentofu-modules.git`
3. Create a feature branch: `git checkout -b feature/my-new-module`
4. Make your changes
5. Test thoroughly
6. Submit a pull request

## Module Development

### Using the Template

Start with the `_template/` directory:

```bash
cp -r _template aws/compute/my-module
cd aws/compute/my-module
```

### Module Structure

Every module must include:

- `main.tf` — Resource definitions
- `variables.tf` — Single `config_file` variable
- `outputs.tf` — Standardized outputs
- `versions.tf` — Provider and OpenTofu version constraints
- `locals.tf` — YAML decode and derived values
- `README.md` — Comprehensive documentation
- `examples/basic/` — Working example with `config.yaml`

Optional files:
- `iam.tf` — IAM resources
- `security.tf` — Security groups / firewall rules

### YAML Configuration

All modules must:
- Accept a single `config_file` variable
- Use `yamldecode(file(var.config_file))` to read configuration
- Support the standard `meta` block (environment, region, name, team, cost_center)
- Support the standard `security` block (encryption_enabled, public_access, deletion_protection, audit_logging)
- Support the standard `tags` or `labels` block

### Security Requirements

All modules must enforce these security defaults:

1. **Encryption at rest** — Enabled by default
2. **Encryption in transit** — TLS enforced
3. **Least privilege IAM** — No wildcard actions or resources
4. **Network isolation** — No public access by default
5. **Audit logging** — Enabled with minimum 90-day retention
6. **Deletion protection** — Enabled by default

Security defaults can be made configurable but must default to the secure option.

### Naming and Tagging

Use the shared modules (see `_template/locals.tf` for the canonical pattern):

```hcl
module "naming" {
  source = "../../../shared/naming"

  environment     = local.config.meta.environment
  team            = local.config.meta.team
  resource_type   = "eks"
  name            = local.config.meta.name
  cloud_provider  = "aws"
}

module "tagging" {
  source = "../../../shared/tagging"

  environment = local.config.meta.environment
  team        = local.config.meta.team
  cost_center = local.config.meta.cost_center
  module_path = "aws/compute/eks"
  custom_tags = lookup(local.config, "tags", {})
}

module "validation" {
  source = "../../../shared/validation"

  config         = local.config
  cloud_provider = "aws"
  resource_type  = "eks"
}
```

The `validation` module is required for every new module; it enforces required `meta` fields, valid environment values, and name format/length at plan time via `terraform_data` preconditions.

### Outputs

Every module must output:

- `resource_id` — Resource identifier
- `resource_arn` — ARN or equivalent (Azure resource ID, GCP self_link)
- `resource_name` — Resource name
- `resource_region` — Resource region

Additional outputs as needed for the resource type.

### Documentation

Your module README must include:

1. **Title and description**
2. **Features** — Bullet list of capabilities
3. **YAML Configuration** — Complete example with inline comments
4. **Usage** — HCL example
5. **Outputs** — Table with descriptions
6. **Security Considerations**
7. **Cost Optimization** — Tips for reducing costs
8. **Troubleshooting** — Common issues
9. **Additional Resources** — Links to provider docs

Use `terraform-docs` to auto-generate parts of the README:

```bash
terraform-docs markdown table . >> README.md
```

## Testing

### Local Testing

1. Navigate to `examples/basic/`
2. Run `tofu init`
3. Run `tofu plan` — Must produce clean plan with no errors
4. Verify outputs are correct

### Static Analysis

Run these tools before submitting:

```bash
# Format check
tofu fmt -check -recursive

# Linting
tflint --init
tflint --recursive

# Security scanning
checkov -d .
trivy config .
```

All checks must pass with zero errors.

### CI Pipeline

Pull requests automatically run:
- `tofu fmt -check`
- `tflint` with provider-specific rulesets
- `checkov` security scanning
- `trivy` misconfiguration scanning
- OPA policy validation
- Example plan validation

## Pull Request Process

1. **Title** — Use format: `[Provider/Category] Brief description`
   - Example: `[AWS/Compute] Add Lambda module`
2. **Description** — Explain what and why
3. **Testing** — Describe how you tested
4. **Breaking Changes** — Call out any breaking changes
5. **Documentation** — Ensure README is complete

### PR Checklist

- [ ] Module follows template structure
- [ ] YAML configuration is documented
- [ ] Security defaults are enforced
- [ ] Example produces clean plan
- [ ] All CI checks pass
- [ ] README is comprehensive
- [ ] Outputs follow naming convention
- [ ] No secrets or credentials in code

## Versioning

Modules use semantic versioning with Git tags:

```bash
git tag aws/compute/lambda/v1.0.0
git push --tags
```

Version bumps:
- **Major (v2.0.0)** — Breaking YAML schema changes
- **Minor (v1.1.0)** — New optional YAML fields
- **Patch (v1.0.1)** — Bug fixes and security patches

## Security Policy

If you discover a security vulnerability:

1. **Do not** open a public issue
2. Email security@example.com with details
3. Include steps to reproduce
4. Allow 90 days for fix before public disclosure

## Questions?

- Open a GitHub Discussion for general questions
- Open an issue for bugs or feature requests
- Tag maintainers for urgent issues

## License

By contributing, you agree that your contributions will be licensed under the Apache 2.0 License.
