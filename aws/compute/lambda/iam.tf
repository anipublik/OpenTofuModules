resource "aws_iam_role" "this" {
  name = "${local.function_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "vpc" {
  count = lookup(local.config, "networking", null) != null ? 1 : 0
  
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "xray" {
  count = lookup(local.config.function, "xray_tracing", true) ? 1 : 0
  
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy" "custom" {
  count = length(lookup(local.config.function, "iam_policy_statements", [])) > 0 ? 1 : 0
  
  name = "${local.function_name}-custom-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = local.config.function.iam_policy_statements
  })
}
