# Module Template

Use this template to bootstrap new modules with the correct structure and boilerplate.

## Usage

```bash
# Copy template to new module location
cp -r _template aws/compute/new-module

# Update files with module-specific details
cd aws/compute/new-module
```

## Files

- `main.tf` — Resource definitions
- `variables.tf` — Single `config_file` variable
- `outputs.tf` — Standardized outputs
- `versions.tf` — Provider and OpenTofu version constraints
- `locals.tf` — YAML decode and derived values
- `iam.tf` — IAM resources (if applicable)
- `security.tf` — Security groups / firewall rules (if applicable)
- `README.md` — Module documentation
- `examples/basic/main.tf` — Example usage
- `examples/basic/config.yaml` — Example YAML config

## Checklist

When creating a new module:

- [ ] Copy template to correct location
- [ ] Update `versions.tf` with correct provider
- [ ] Implement resources in `main.tf`
- [ ] Add YAML decode logic to `locals.tf`
- [ ] Define outputs in `outputs.tf`
- [ ] Create IAM resources in `iam.tf` (if needed)
- [ ] Create security resources in `security.tf` (if needed)
- [ ] Write comprehensive README with YAML schema
- [ ] Create working example in `examples/basic/`
- [ ] Test example with `tofu plan`
- [ ] Run `tflint` and `checkov`
- [ ] Generate docs with `terraform-docs`
- [ ] Commit with module version tag

## README Template

Your module README should include:

1. **Title and description**
2. **Features** — Bullet list of key capabilities
3. **YAML Configuration** — Complete example with comments
4. **Usage** — HCL example showing module invocation
5. **Outputs** — Table of all outputs with descriptions
6. **Security Considerations** — Provider-specific security notes
7. **Cost Optimization** — Tips for reducing costs
8. **Troubleshooting** — Common issues and solutions
9. **Additional Resources** — Links to provider docs

## YAML Schema Documentation

Use this format in your README:

```yaml
meta:
  environment: production    # Required — one of: dev, staging, production
  region: us-east-1         # Required — valid provider region
  name: my-resource         # Required — resource identifier
  team: platform            # Required — team name for tagging
  cost_center: eng-001      # Required — cost allocation tag

# Resource-specific configuration
resource:
  field: value              # Description of field
  nested:
    field: value            # Description of nested field

security:
  encryption_enabled: true          # Default true — enable encryption at rest
  public_access: false              # Default false — allow public access
  deletion_protection: true         # Default true — prevent accidental deletion
  audit_logging: true               # Default true — enable audit logs

tags:                       # Optional — custom tags merged with required tags
  custom_tag: value
```

## Output Documentation

Use this table format:

| Output | Description |
|--------|-------------|
| `resource_id` | Resource identifier |
| `resource_arn` | Resource ARN (or equivalent) |
| `resource_name` | Resource name |
| `resource_region` | Resource region |

## Version Tagging

Tag your module with semantic versioning:

```bash
git tag aws/compute/new-module/v1.0.0
git push --tags
```

Version bumps:
- **Major** — Breaking YAML schema changes
- **Minor** — New optional YAML fields
- **Patch** — Bug fixes and security patches
