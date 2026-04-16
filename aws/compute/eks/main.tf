resource "aws_eks_cluster" "this" {
  name     = local.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = local.config.cluster.kubernetes_version

  vpc_config {
    subnet_ids              = local.config.networking.subnet_ids
    endpoint_private_access = local.config.cluster.endpoint_private_access
    endpoint_public_access  = local.config.cluster.endpoint_public_access
    public_access_cidrs     = local.config.cluster.endpoint_public_access ? lookup(local.config.cluster, "public_access_cidrs", ["0.0.0.0/0"]) : []
    security_group_ids      = lookup(local.config.networking, "cluster_security_group_ids", [])
  }

  encryption_config {
    provider {
      key_arn = local.kms_key_arn
    }
    resources = ["secrets"]
  }

  # Logging block is optional; default to disabled if not specified.
  enabled_cluster_log_types = lookup(lookup(local.config.cluster, "logging", {}), "enabled", false) ? lookup(local.config.cluster.logging, "types", []) : []

  tags = local.tags

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy_attachment.vpc_resource_controller,
  ]
}

resource "aws_eks_node_group" "this" {
  for_each = { for ng in local.config.node_groups : ng.name => ng }

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = each.value.name
  node_role_arn   = aws_iam_role.node_group.arn
  subnet_ids      = local.config.networking.subnet_ids

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  instance_types = each.value.instance_types
  capacity_type  = lookup(each.value, "capacity_type", "ON_DEMAND")
  disk_size      = lookup(each.value, "disk_size", 100)

  labels = lookup(each.value, "labels", {})

  dynamic "taint" {
    for_each = lookup(each.value, "taints", [])
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  launch_template {
    id      = aws_launch_template.node_group[each.key].id
    version = "$Latest"
  }

  tags = merge(local.tags, {
    Name = "${local.cluster_name}-${each.value.name}"
  })

  depends_on = [
    aws_iam_role_policy_attachment.node_group_policy,
    aws_iam_role_policy_attachment.node_group_cni_policy,
    aws_iam_role_policy_attachment.node_group_registry_policy,
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [scaling_config[0].desired_size]
  }
}

resource "aws_launch_template" "node_group" {
  for_each = { for ng in local.config.node_groups : ng.name => ng }

  name_prefix = "${local.cluster_name}-${each.value.name}-"

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = lookup(each.value, "disk_size", 100)
      volume_type           = "gp3"
      encrypted             = lookup(each.value, "disk_encrypted", true)
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"  # IMDSv2
    http_put_response_hop_limit = 1
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.tags, {
      Name = "${local.cluster_name}-${each.value.name}"
    })
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_addon" "vpc_cni" {
  count = lookup(local.config, "addons", null) != null ? 1 : 0

  cluster_name      = aws_eks_cluster.this.name
  addon_name        = "vpc-cni"
  addon_version     = lookup(local.config.addons.vpc_cni, "version", null)
  resolve_conflicts_on_create = lookup(local.config.addons.vpc_cni, "resolve_conflicts", "OVERWRITE")
  resolve_conflicts_on_update = lookup(local.config.addons.vpc_cni, "resolve_conflicts", "OVERWRITE")

  tags = local.tags
}

resource "aws_eks_addon" "coredns" {
  count = lookup(local.config, "addons", null) != null ? 1 : 0

  cluster_name      = aws_eks_cluster.this.name
  addon_name        = "coredns"
  addon_version     = lookup(local.config.addons.coredns, "version", null)
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = local.tags

  depends_on = [aws_eks_node_group.this]
}

resource "aws_eks_addon" "kube_proxy" {
  count = lookup(local.config, "addons", null) != null ? 1 : 0

  cluster_name      = aws_eks_cluster.this.name
  addon_name        = "kube-proxy"
  addon_version     = lookup(local.config.addons.kube_proxy, "version", null)
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  tags = local.tags
}

# OIDC provider for IRSA
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer

  tags = local.tags
}
