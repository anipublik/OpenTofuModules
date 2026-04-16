resource "datadog_dashboard" "this" {
  title       = local.dashboard_name
  description = lookup(local.config.dashboard, "description", "")
  layout_type = "free"

  dynamic "widget" {
    for_each = local.config.dashboard.widgets
    content {
      layout {
        x      = widget.value.layout.x
        y      = widget.value.layout.y
        width  = widget.value.layout.width
        height = widget.value.layout.height
      }

      dynamic "timeseries_definition" {
        for_each = lookup(widget.value, "type", "") == "timeseries" ? [widget.value] : []
        content {
          title       = lookup(timeseries_definition.value, "title", "")
          show_legend = lookup(timeseries_definition.value, "show_legend", true)

          dynamic "request" {
            for_each = lookup(timeseries_definition.value, "requests", [])
            content {
              q            = lookup(request.value, "query", "")
              display_type = lookup(request.value, "display_type", "line")
            }
          }
        }
      }

      dynamic "note_definition" {
        for_each = lookup(widget.value, "type", "") == "note" ? [widget.value] : []
        content {
          content          = note_definition.value.content
          background_color = lookup(note_definition.value, "background_color", "white")
          font_size        = lookup(note_definition.value, "font_size", "14")
          text_align       = lookup(note_definition.value, "text_align", "left")
          show_tick        = lookup(note_definition.value, "show_tick", false)
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
}
