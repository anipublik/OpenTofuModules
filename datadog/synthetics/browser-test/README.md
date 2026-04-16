# Datadog Browser Test

Monitor browser-based user journeys with automated testing.

## Features

- **Multi-Step Workflows** — Test complete user journeys
- **Browser Actions** — Click, type, navigate, scroll
- **Element Assertions** — Verify element presence and content
- **Screenshot Capture** — Capture screenshots on failure
- **Multiple Devices** — Test on desktop, tablet, mobile

## Usage

```hcl
module "browser_test" {
  source = "./datadog/synthetics/browser-test"
  config_file = "synthetics/login-flow.yaml"
}
```

## Step Types

- `goToUrl` — Navigate to URL
- `click` — Click element
- `typeText` — Type into input
- `assertElementPresent` — Verify element exists
