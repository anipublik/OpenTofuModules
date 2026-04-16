resource "datadog_dashboard" "this" {
  title       = local.dashboard_name
  description = lookup(local.config.dashboard, "description", "")
  layout_type = "ordered"

  dynamic "widget" {
    for_each = local.config.dashboard.widgets
    content {
      dynamic "timeseries_definition" {
        for_each = lookup(widget.value, "type", "") == "timeseries" ? [widget.value] : []
        content {
          title       = lookup(timeseries_definition.value, "title", "")
          show_legend = lookup(timeseries_definition.value, "show_legend", true)
          legend_size = lookup(timeseries_definition.value, "legend_size", "0")

          dynamic "request" {
            for_each = lookup(timeseries_definition.value, "requests", [])
            content {
              q              = lookup(request.value, "query", "")
              display_type   = lookup(request.value, "display_type", "line")
              style {
                palette    = lookup(request.value, "palette", "dog_classic")
                line_type  = lookup(request.value, "line_type", "solid")
                line_width = lookup(request.value, "line_width", "normal")
              }
            }
          }
        }
      }

      dynamic "query_value_definition" {
        for_each = lookup(widget.value, "type", "") == "query_value" ? [widget.value] : []
        content {
          title      = lookup(query_value_definition.value, "title", "")
          autoscale  = lookup(query_value_definition.value, "autoscale", true)
          precision  = lookup(query_value_definition.value, "precision", 2)

          dynamic "request" {
            for_each = lookup(query_value_definition.value, "requests", [])
            content {
              q          = lookup(request.value, "query", "")
              aggregator = lookup(request.value, "aggregator", "avg")
            }
          }
        }
      }
    }
  }

  dynamic "template_variable" {
    for_each = lookup(local.config.dashboard, "template_variables", [])
    content {
      name    = template_variable.value.name
      prefix  = lookup(template_variable.value, "prefix", null)
      default = lookup(template_variable.value, "default", null)
    }
  }

  notify_list = lookup(local.config.dashboard, "notify_list", [])
}
