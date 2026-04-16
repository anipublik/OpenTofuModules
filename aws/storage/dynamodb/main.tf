resource "aws_dynamodb_table" "this" {
  name           = local.table_name
  billing_mode   = lookup(local.config.table, "billing_mode", "PAY_PER_REQUEST")
  hash_key       = local.config.table.hash_key
  range_key      = lookup(local.config.table, "range_key", null)
  
  read_capacity  = lookup(local.config.table, "billing_mode", "PAY_PER_REQUEST") == "PROVISIONED" ? lookup(local.config.table, "read_capacity", 5) : null
  write_capacity = lookup(local.config.table, "billing_mode", "PAY_PER_REQUEST") == "PROVISIONED" ? lookup(local.config.table, "write_capacity", 5) : null

  dynamic "attribute" {
    for_each = local.config.table.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = lookup(local.config.table, "global_secondary_indexes", [])
    content {
      name               = global_secondary_index.value.name
      hash_key           = global_secondary_index.value.hash_key
      range_key          = lookup(global_secondary_index.value, "range_key", null)
      projection_type    = lookup(global_secondary_index.value, "projection_type", "ALL")
      non_key_attributes = lookup(global_secondary_index.value, "non_key_attributes", null)
      read_capacity      = lookup(local.config.table, "billing_mode", "PAY_PER_REQUEST") == "PROVISIONED" ? lookup(global_secondary_index.value, "read_capacity", 5) : null
      write_capacity     = lookup(local.config.table, "billing_mode", "PAY_PER_REQUEST") == "PROVISIONED" ? lookup(global_secondary_index.value, "write_capacity", 5) : null
    }
  }

  dynamic "local_secondary_index" {
    for_each = lookup(local.config.table, "local_secondary_indexes", [])
    content {
      name               = local_secondary_index.value.name
      range_key          = local_secondary_index.value.range_key
      projection_type    = lookup(local_secondary_index.value, "projection_type", "ALL")
      non_key_attributes = lookup(local_secondary_index.value, "non_key_attributes", null)
    }
  }

  ttl {
    enabled        = lookup(local.config.table, "ttl_enabled", false)
    attribute_name = lookup(local.config.table, "ttl_attribute", "")
  }

  server_side_encryption {
    enabled     = local.config.security.encryption_enabled
    kms_key_arn = local.kms_key_arn
  }

  point_in_time_recovery {
    enabled = lookup(local.config.reliability, "point_in_time_recovery", true)
  }

  stream_enabled   = lookup(local.config.table, "stream_enabled", false)
  stream_view_type = lookup(local.config.table, "stream_enabled", false) ? lookup(local.config.table, "stream_view_type", "NEW_AND_OLD_IMAGES") : null

  deletion_protection_enabled = local.config.security.deletion_protection

  tags = local.tags

  lifecycle {
    ignore_changes = [read_capacity, write_capacity]
  }
}

resource "aws_appautoscaling_target" "read" {
  count = lookup(local.config.table, "billing_mode", "PAY_PER_REQUEST") == "PROVISIONED" && lookup(local.config.table, "autoscaling_enabled", false) ? 1 : 0

  max_capacity       = lookup(local.config.table.autoscaling, "read_max_capacity", 100)
  min_capacity       = lookup(local.config.table.autoscaling, "read_min_capacity", 5)
  resource_id        = "table/${aws_dynamodb_table.this.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "read" {
  count = lookup(local.config.table, "billing_mode", "PAY_PER_REQUEST") == "PROVISIONED" && lookup(local.config.table, "autoscaling_enabled", false) ? 1 : 0

  name               = "${local.table_name}-read-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read[0].resource_id
  scalable_dimension = aws_appautoscaling_target.read[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.read[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = lookup(local.config.table.autoscaling, "read_target_utilization", 70)
  }
}

resource "aws_appautoscaling_target" "write" {
  count = lookup(local.config.table, "billing_mode", "PAY_PER_REQUEST") == "PROVISIONED" && lookup(local.config.table, "autoscaling_enabled", false) ? 1 : 0

  max_capacity       = lookup(local.config.table.autoscaling, "write_max_capacity", 100)
  min_capacity       = lookup(local.config.table.autoscaling, "write_min_capacity", 5)
  resource_id        = "table/${aws_dynamodb_table.this.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "write" {
  count = lookup(local.config.table, "billing_mode", "PAY_PER_REQUEST") == "PROVISIONED" && lookup(local.config.table, "autoscaling_enabled", false) ? 1 : 0

  name               = "${local.table_name}-write-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write[0].resource_id
  scalable_dimension = aws_appautoscaling_target.write[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.write[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = lookup(local.config.table.autoscaling, "write_target_utilization", 70)
  }
}
