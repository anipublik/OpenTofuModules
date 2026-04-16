# GCP Cloud Storage Module

Production-hardened Cloud Storage bucket with encryption, versioning, and lifecycle management.

## Features

- **Uniform Bucket-Level Access** — IAM-only access control (no ACLs)
- **Public Access Prevention** — Enforced by default
- **Encryption at Rest** — Customer-managed encryption keys (CMEK) support
- **Object Versioning** — Retain previous versions of objects
- **Lifecycle Management** — Automatic object deletion and storage class transitions
- **Access Logging** — Log all bucket access to another bucket
- **Multi-Regional Storage** — High availability across regions
- **IAM Bindings** — Fine-grained access control

## YAML Configuration

```yaml
meta:
  environment: production
  region: us-central1
  name: app-data
  team: backend
  cost_center: eng-002

gcp:
  project_id: my-gcp-project

bucket:
  location: US                         # or EU, ASIA, us-central1, etc.
  storage_class: STANDARD              # or NEARLINE, COLDLINE, ARCHIVE
  versioning: true
  
  lifecycle_rules:
    - action:
        type: Delete
      condition:
        age: 90                        # Delete after 90 days
        with_state: ARCHIVED
    
    - action:
        type: SetStorageClass
        storage_class: NEARLINE
      condition:
        age: 30                        # Move to Nearline after 30 days
        matches_storage_class:
          - STANDARD
    
    - action:
        type: Delete
      condition:
        num_newer_versions: 3          # Keep only 3 versions
  
  logging_bucket: my-project-logs      # Optional access logging
  logging_prefix: gcs-logs/
  
  iam_bindings:
    - role: roles/storage.objectViewer
      members:
        - serviceAccount:app@my-project.iam.gserviceaccount.com
    
    - role: roles/storage.objectAdmin
      members:
        - group:backend-team@example.com

security:
  encryption_enabled: true
  kms_key_id: projects/my-project/locations/us-central1/keyRings/my-keyring/cryptoKeys/gcs-key
  public_access: false                 # Enforce public access prevention
  deletion_protection: false           # Not supported for GCS

tags:
  project: backend
  compliance: pci-dss
```

## Usage

```hcl
module "gcs" {
  source = "./gcp/storage/gcs"
  config_file = "gcs.yaml"
}

output "bucket_name" {
  value = module.gcs.bucket_name
}

output "bucket_url" {
  value = module.gcs.bucket_url
}
```

## Outputs

| Output | Description |
|--------|-------------|
| `bucket_id` | Bucket ID |
| `bucket_name` | Bucket name |
| `bucket_url` | Bucket URL (gs://) |
| `bucket_self_link` | Bucket self link |

## Storage Classes

Choose based on access patterns:

- **STANDARD** — Frequently accessed data, highest cost
- **NEARLINE** — Accessed less than once per month, 30-day minimum
- **COLDLINE** — Accessed less than once per quarter, 90-day minimum
- **ARCHIVE** — Accessed less than once per year, 365-day minimum

## Locations

**Multi-Regional:**
- `US` — United States (multiple regions)
- `EU` — European Union (multiple regions)
- `ASIA` — Asia (multiple regions)

**Regional:**
- `us-central1`, `us-east1`, `us-west1`
- `europe-west1`, `europe-west2`
- `asia-east1`, `asia-southeast1`

## Lifecycle Rules

### Delete Old Objects

```yaml
lifecycle_rules:
  - action:
      type: Delete
    condition:
      age: 365                         # Delete after 1 year
```

### Transition to Cheaper Storage

```yaml
lifecycle_rules:
  - action:
      type: SetStorageClass
      storage_class: NEARLINE
    condition:
      age: 30
      matches_storage_class:
        - STANDARD
  
  - action:
      type: SetStorageClass
      storage_class: COLDLINE
    condition:
      age: 90
      matches_storage_class:
        - NEARLINE
```

### Version Management

```yaml
lifecycle_rules:
  - action:
      type: Delete
    condition:
      num_newer_versions: 5            # Keep only 5 versions
      with_state: ARCHIVED
```

## IAM Roles

Common roles for bucket access:

- `roles/storage.objectViewer` — Read objects
- `roles/storage.objectCreator` — Create objects
- `roles/storage.objectAdmin` — Full object control
- `roles/storage.admin` — Full bucket and object control

## Accessing Objects

### Using gsutil

```bash
# Upload file
gsutil cp file.txt gs://app-data-production/

# Download file
gsutil cp gs://app-data-production/file.txt .

# List objects
gsutil ls gs://app-data-production/

# Sync directory
gsutil -m rsync -r ./local-dir gs://app-data-production/remote-dir/
```

### Using Application Code

```python
from google.cloud import storage

client = storage.Client()
bucket = client.bucket('app-data-production')

# Upload
blob = bucket.blob('file.txt')
blob.upload_from_filename('local-file.txt')

# Download
blob = bucket.blob('file.txt')
blob.download_to_filename('local-file.txt')
```

## Security Considerations

- **Public Access Prevention** — Enforced by default, prevents accidental public exposure
- **Uniform Bucket-Level Access** — IAM-only access control, no legacy ACLs
- **CMEK** — Use customer-managed encryption keys for compliance
- **Access Logging** — Enable for audit trails
- **Signed URLs** — Use for temporary access without IAM permissions
- **VPC Service Controls** — Restrict bucket access to specific VPCs

## Cost Optimization

- **Storage Class** — Use NEARLINE/COLDLINE/ARCHIVE for infrequently accessed data
- **Lifecycle Rules** — Automatically transition or delete old objects
- **Multi-Regional vs Regional** — Regional is cheaper if data locality not required
- **Compression** — Compress objects before upload to reduce storage costs
- **Requester Pays** — Enable for public datasets to shift egress costs to users

## Versioning and Recovery

Enable versioning to protect against accidental deletion:

```yaml
bucket:
  versioning: true
```

**Restore Previous Version:**
```bash
# List versions
gsutil ls -a gs://app-data-production/file.txt

# Copy old version to current
gsutil cp gs://app-data-production/file.txt#1234567890 \
  gs://app-data-production/file.txt
```

## Troubleshooting

**Permission denied errors:**
- Verify service account has required IAM role
- Check public access prevention is not blocking access
- Ensure uniform bucket-level access is enabled

**Slow upload/download:**
- Use `gsutil -m` for parallel transfers
- Enable gzip compression for text files
- Consider using Cloud Storage Transfer Service for large datasets

**Lifecycle rules not working:**
- Verify rule conditions match object state
- Check rule action is valid for storage class
- Rules run once per day, not immediately

## Additional Resources

- [Cloud Storage Documentation](https://cloud.google.com/storage/docs)
- [gsutil Tool](https://cloud.google.com/storage/docs/gsutil)
- [Lifecycle Management](https://cloud.google.com/storage/docs/lifecycle)
- [Access Control](https://cloud.google.com/storage/docs/access-control)
