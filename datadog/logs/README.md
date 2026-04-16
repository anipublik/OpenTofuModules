# Datadog Logs

Process, index, and archive logs with pipelines and retention policies.

## Modules

### [Pipeline](./pipeline/README.md)
Log processing pipelines with:
- Grok parsers for log parsing
- Date remappers for timestamp extraction
- Attribute remappers for field mapping
- Status remappers for log level normalization

### [Index](./index/README.md)
Log indexes with:
- Query-based filtering
- Retention period configuration
- Daily volume limits
- Exclusion filters for sampling

### [Archive](./archive/README.md)
Long-term log storage with:
- S3, GCS, and Azure Blob support
- Query-based filtering
- Rehydration for analysis
- Tag inclusion for context
