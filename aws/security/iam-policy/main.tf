resource "aws_iam_policy" "this" {
  name        = local.policy_name
  description = lookup(local.config.policy, "description", "IAM policy ${local.policy_name}")
  path        = lookup(local.config.policy, "path", "/")
  policy      = jsonencode(local.config.policy.policy_document)

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = toset(lookup(local.config.policy, "attach_to_roles", []))

  role       = each.value
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_user_policy_attachment" "this" {
  for_each = toset(lookup(local.config.policy, "attach_to_users", []))

  user       = each.value
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_group_policy_attachment" "this" {
  for_each = toset(lookup(local.config.policy, "attach_to_groups", []))

  group      = each.value
  policy_arn = aws_iam_policy.this.arn
}
