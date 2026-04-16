resource "aws_lambda_function" "this" {
  function_name = local.function_name
  role          = aws_iam_role.this.arn

  filename          = lookup(local.config.function, "filename", null)
  s3_bucket         = lookup(local.config.function, "s3_bucket", null)
  s3_key            = lookup(local.config.function, "s3_key", null)
  s3_object_version = lookup(local.config.function, "s3_object_version", null)

  handler       = local.config.function.handler
  runtime       = local.config.function.runtime
  architectures = lookup(local.config.function, "architectures", ["x86_64"])

  memory_size = lookup(local.config.function, "memory_size", 128)
  timeout     = lookup(local.config.function, "timeout", 3)

  reserved_concurrent_executions = lookup(local.config.function, "reserved_concurrent_executions", -1)

  environment {
    variables = lookup(local.config.function, "environment_variables", {})
  }

  dynamic "vpc_config" {
    for_each = lookup(local.config, "networking", null) != null ? [1] : []
    content {
      subnet_ids         = local.config.networking.subnet_ids
      security_group_ids = [aws_security_group.this[0].id]
    }
  }

  dynamic "dead_letter_config" {
    for_each = lookup(local.config.function, "dead_letter_queue_arn", null) != null ? [1] : []
    content {
      target_arn = local.config.function.dead_letter_queue_arn
    }
  }

  kms_key_arn = local.kms_key_arn

  tracing_config {
    mode = lookup(local.config.function, "xray_tracing", true) ? "Active" : "PassThrough"
  }

  tags = local.tags

  depends_on = [
    aws_iam_role_policy_attachment.basic,
    aws_iam_role_policy_attachment.vpc,
    aws_cloudwatch_log_group.this
  ]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${local.function_name}"
  retention_in_days = lookup(local.config.function, "log_retention_days", 30)
  kms_key_id        = local.kms_key_arn

  tags = local.tags
}

resource "aws_lambda_permission" "this" {
  for_each = { for idx, trigger in lookup(local.config.function, "triggers", []) : idx => trigger }

  statement_id  = "AllowExecutionFrom${each.value.service}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "${each.value.service}.amazonaws.com"
  source_arn    = lookup(each.value, "source_arn", null)
}
