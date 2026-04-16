resource "aws_iam_role" "this" {
  name                 = local.role_name
  description          = lookup(local.config.role, "description", "IAM role ${local.role_name}")
  assume_role_policy   = jsonencode(local.assume_role_policy)
  max_session_duration = lookup(local.config.role, "max_session_duration", 3600)
  
  dynamic "inline_policy" {
    for_each = lookup(local.config.role, "inline_policies", [])
    content {
      name   = inline_policy.value.name
      policy = jsonencode(inline_policy.value.policy)
    }
  }

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each = toset(lookup(local.config.role, "managed_policy_arns", []))

  role       = aws_iam_role.this.name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "this" {
  count = lookup(local.config.role, "create_instance_profile", false) ? 1 : 0

  name = "${local.role_name}-profile"
  role = aws_iam_role.this.name

  tags = local.tags
}
