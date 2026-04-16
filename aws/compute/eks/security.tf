# KMS key for EKS secrets encryption
resource "aws_kms_key" "eks" {
  count = lookup(lookup(local.config.cluster, "encryption", {}), "kms_key_id", null) == null ? 1 : 0

  description             = "KMS key for EKS cluster ${local.cluster_name} secrets encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(local.tags, {
    Name = "${local.cluster_name}-eks-secrets"
  })
}

resource "aws_kms_alias" "eks" {
  count = lookup(lookup(local.config.cluster, "encryption", {}), "kms_key_id", null) == null ? 1 : 0

  name          = "alias/${local.cluster_name}-eks-secrets"
  target_key_id = aws_kms_key.eks[0].key_id
}

# Cluster security group rules
resource "aws_security_group" "cluster" {
  name_prefix = "${local.cluster_name}-cluster-"
  description = "EKS cluster security group for ${local.cluster_name}"
  vpc_id      = local.config.networking.vpc_id

  tags = merge(local.tags, {
    Name = "${local.cluster_name}-cluster-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "cluster_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.cluster.id
  description       = "Allow all outbound traffic"
}

# Node security group
resource "aws_security_group" "node" {
  name_prefix = "${local.cluster_name}-node-"
  description = "EKS node security group for ${local.cluster_name}"
  vpc_id      = local.config.networking.vpc_id

  tags = merge(local.tags, {
    Name                                        = "${local.cluster_name}-node-sg"
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "node_ingress_self" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.node.id
  description       = "Allow nodes to communicate with each other"
}

resource "aws_security_group_rule" "node_ingress_cluster" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cluster.id
  security_group_id        = aws_security_group.node.id
  description              = "Allow pods to receive communication from cluster control plane"
}

resource "aws_security_group_rule" "node_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.node.id
  description       = "Allow all outbound traffic"
}

resource "aws_security_group_rule" "cluster_ingress_node" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.node.id
  security_group_id        = aws_security_group.cluster.id
  description              = "Allow pods to communicate with cluster API server"
}
