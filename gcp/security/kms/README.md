# GCP KMS Module

Production-hardened Cloud KMS with key rotation and IAM.

## Features

- **Key Rotation** — Automatic rotation
- **Key Rings** — Logical grouping
- **Crypto Keys** — Encryption keys
- **IAM Bindings** — Access control
- **Prevent Destroy** — Deletion protection

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: data-encryption
  team: platform
  cost_center: eng-001

keys:
  - name: database-key
    rotation_period: 7776000s  # 90 days
    algorithm: GOOGLE_SYMMETRIC_ENCRYPTION
    protection_level: SOFTWARE
    purpose: ENCRYPT_DECRYPT
    prevent_destroy: true
  
  - name: signing-key
    algorithm: RSA_SIGN_PSS_2048_SHA256
    purpose: ASYMMETRIC_SIGN

iam_bindings:
  - key_index: 0
    role: roles/cloudkms.cryptoKeyEncrypterDecrypter
    members:
      - serviceAccount:app@my-project.iam.gserviceaccount.com

gcp:
  project_id: my-project

tags:
  data_classification: critical
```

## Usage

```hcl
module "kms" {
  source = "./gcp/security/kms"
  config_file = "kms.yaml"
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `resource_id` | Key ring ID |
| `key_ring_id` | Key ring ID |
| `crypto_key_ids` | Map of crypto key IDs |
