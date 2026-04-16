# Datadog API Test

Monitor HTTP/HTTPS endpoints with automated testing.

## Features

- **HTTP Methods** — GET, POST, PUT, DELETE, PATCH
- **Custom Headers** — Add authentication and custom headers
- **Body Validation** — Assert response body content
- **Response Time** — Monitor API latency
- **Multi-Location** — Test from multiple regions

## Usage

```hcl
module "api_test" {
  source = "./datadog/synthetics/api-test"
  config_file = "synthetics/api-health.yaml"
}
```

## Available Locations

- `aws:us-east-1`, `aws:us-west-2`, `aws:eu-west-1`
- `azure:eastus`, `azure:westeurope`
- `gcp:us-central1`, `gcp:europe-west1`
