resource "aws_launch_template" "this" {
  name_prefix   = "${local.instance_name}-"
  image_id      = local.config.instance.ami
  instance_type = local.config.instance.instance_type
  key_name      = lookup(local.config.instance, "key_name", null)

  iam_instance_profile {
    arn = aws_iam_instance_profile.this.arn
  }

  vpc_security_group_ids = concat([aws_security_group.this.id], lookup(local.config.networking, "additional_security_groups", []))

  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size           = lookup(local.config.instance, "root_volume_size", 20)
      volume_type           = lookup(local.config.instance, "root_volume_type", "gp3")
      encrypted             = local.config.security.encryption_enabled
      kms_key_id            = local.kms_key_id
      delete_on_termination = true
    }
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2
    http_put_response_hop_limit = 1
  }

  monitoring {
    enabled = lookup(local.config.instance, "detailed_monitoring", true)
  }

  user_data = base64encode(lookup(local.config.instance, "user_data", ""))

  tag_specifications {
    resource_type = "instance"
    tags = merge(local.tags, {
      Name = local.instance_name
    })
  }

  tag_specifications {
    resource_type = "volume"
    tags          = local.tags
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  name                = local.instance_name
  vpc_zone_identifier = local.config.networking.subnet_ids

  min_size         = lookup(local.config.autoscaling, "min_size", 1)
  max_size         = lookup(local.config.autoscaling, "max_size", 10)
  desired_capacity = lookup(local.config.autoscaling, "desired_size", 2)

  health_check_type         = lookup(local.config.autoscaling, "health_check_type", "EC2")
  health_check_grace_period = lookup(local.config.autoscaling, "health_check_grace_period", 300)

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  dynamic "tag" {
    for_each = local.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  tag {
    key                 = "Name"
    value               = local.instance_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

resource "aws_autoscaling_policy" "cpu" {
  name                   = "${local.instance_name}-cpu-scaling"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = lookup(local.config.autoscaling, "target_cpu_utilization", 70)
  }
}

resource "aws_iam_instance_profile" "this" {
  name = "${local.instance_name}-profile"
  role = aws_iam_role.this.name

  tags = local.tags
}

resource "aws_iam_role" "this" {
  name = "${local.instance_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy" "custom" {
  count = length(lookup(local.config.instance, "iam_policy_statements", [])) > 0 ? 1 : 0

  name = "${local.instance_name}-custom-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.config.instance.iam_policy_statements
  })
}

resource "aws_security_group" "this" {
  name_prefix = "${local.instance_name}-"
  description = "Security group for EC2 instances ${local.instance_name}"
  vpc_id      = local.config.networking.vpc_id

  tags = merge(local.tags, {
    Name = "${local.instance_name}-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.this.id
  description       = "Allow all outbound traffic"
}

dynamic "aws_security_group_rule" "ingress" {
  for_each = lookup(local.config.networking, "ingress_rules", [])
  content {
    type                     = "ingress"
    from_port                = ingress.value.from_port
    to_port                  = ingress.value.to_port
    protocol                 = ingress.value.protocol
    cidr_blocks              = lookup(ingress.value, "cidr_blocks", null)
    source_security_group_id = lookup(ingress.value, "source_security_group_id", null)
    security_group_id        = aws_security_group.this.id
    description              = lookup(ingress.value, "description", "")
  }
}
