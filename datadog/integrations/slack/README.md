# Datadog Slack Integration

Send Datadog alerts to Slack channels.

## Features

- **Multi-Channel Support** — Configure multiple channels
- **Customizable Display** — Control message format
- **Snapshot Inclusion** — Include metric snapshots
- **Tag Display** — Show or hide tags

## Usage

```hcl
module "slack_integration" {
  source = "./datadog/integrations/slack"
  config_file = "integrations/slack.yaml"
}
```
