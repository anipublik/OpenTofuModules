resource "datadog_logs_custom_pipeline" "this" {
  name       = local.pipeline_name
  is_enabled = lookup(local.config.pipeline, "enabled", true)
  filter {
    query = local.config.pipeline.filter
  }

  dynamic "processor" {
    for_each = lookup(local.config.pipeline, "processors", [])
    content {
      dynamic "grok_parser" {
        for_each = lookup(processor.value, "type", "") == "grok-parser" ? [processor.value] : []
        content {
          name    = grok_parser.value.name
          is_enabled = lookup(grok_parser.value, "enabled", true)
          source  = lookup(grok_parser.value, "source", "message")
          samples = lookup(grok_parser.value, "samples", [])
          grok {
            support_rules = lookup(grok_parser.value, "support_rules", "")
            match_rules   = grok_parser.value.match_rules
          }
        }
      }

      dynamic "date_remapper" {
        for_each = lookup(processor.value, "type", "") == "date-remapper" ? [processor.value] : []
        content {
          name       = date_remapper.value.name
          is_enabled = lookup(date_remapper.value, "enabled", true)
          sources    = date_remapper.value.sources
        }
      }

      dynamic "attribute_remapper" {
        for_each = lookup(processor.value, "type", "") == "attribute-remapper" ? [processor.value] : []
        content {
          name                 = attribute_remapper.value.name
          is_enabled           = lookup(attribute_remapper.value, "enabled", true)
          sources              = attribute_remapper.value.sources
          source_type          = attribute_remapper.value.source_type
          target               = attribute_remapper.value.target
          target_type          = attribute_remapper.value.target_type
          preserve_source      = lookup(attribute_remapper.value, "preserve_source", false)
          override_on_conflict = lookup(attribute_remapper.value, "override_on_conflict", false)
        }
      }

      dynamic "status_remapper" {
        for_each = lookup(processor.value, "type", "") == "status-remapper" ? [processor.value] : []
        content {
          name       = status_remapper.value.name
          is_enabled = lookup(status_remapper.value, "enabled", true)
          sources    = status_remapper.value.sources
        }
      }
    }
  }
}
