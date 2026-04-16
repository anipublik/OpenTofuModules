resource "aws_ecs_cluster" "this" {
  name = local.cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      kms_key_id = local.kms_key_id
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.this.name
      }
    }
  }

  tags = local.tags
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = local.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = lookup(local.config.task, "cpu", "256")
  memory                   = lookup(local.config.task, "memory", "512")
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([{
    name      = local.config.task.container_name
    image     = local.config.task.image
    essential = true

    portMappings = [{
      containerPort = local.config.task.container_port
      protocol      = "tcp"
    }]

    environment = [
      for k, v in lookup(local.config.task, "environment_variables", {}) : {
        name  = k
        value = v
      }
    ]

    secrets = [
      for k, v in lookup(local.config.task, "secrets", {}) : {
        name      = k
        valueFrom = v
      }
    ]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.app.name
        "awslogs-region"        = local.config.meta.region
        "awslogs-stream-prefix" = "ecs"
      }
    }

    healthCheck = lookup(local.config.task, "health_check", null) != null ? {
      command     = local.config.task.health_check.command
      interval    = lookup(local.config.task.health_check, "interval", 30)
      timeout     = lookup(local.config.task.health_check, "timeout", 5)
      retries     = lookup(local.config.task.health_check, "retries", 3)
      startPeriod = lookup(local.config.task.health_check, "start_period", 0)
    } : null
  }])

  tags = local.tags
}

resource "aws_ecs_service" "this" {
  name            = local.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = lookup(local.config.service, "desired_count", 2)
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = local.config.networking.subnet_ids
    security_groups  = [aws_security_group.this.id]
    assign_public_ip = lookup(local.config.networking, "assign_public_ip", false)
  }

  dynamic "load_balancer" {
    for_each = lookup(local.config.service, "load_balancer", null) != null ? [1] : []
    content {
      target_group_arn = local.config.service.load_balancer.target_group_arn
      container_name   = local.config.task.container_name
      container_port   = local.config.task.container_port
    }
  }

  dynamic "service_registries" {
    for_each = lookup(local.config.service, "service_discovery_arn", null) != null ? [1] : []
    content {
      registry_arn = local.config.service.service_discovery_arn
    }
  }

  health_check_grace_period_seconds = lookup(local.config.service, "health_check_grace_period", 0)

  deployment_configuration {
    maximum_percent         = 200
    minimum_healthy_percent = 100
  }

  enable_execute_command = true

  tags = local.tags

  depends_on = [aws_iam_role_policy_attachment.execution]
}

resource "aws_appautoscaling_target" "this" {
  max_capacity       = lookup(local.config.service, "max_capacity", 10)
  min_capacity       = lookup(local.config.service, "min_capacity", 2)
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.this.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "cpu" {
  name               = "${local.service_name}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = lookup(local.config.service, "target_cpu_utilization", 70)
  }
}

resource "aws_appautoscaling_policy" "memory" {
  name               = "${local.service_name}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.this.resource_id
  scalable_dimension = aws_appautoscaling_target.this.scalable_dimension
  service_namespace  = aws_appautoscaling_target.this.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = lookup(local.config.service, "target_memory_utilization", 80)
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/ecs/${local.cluster_name}"
  retention_in_days = 30
  kms_key_id        = local.kms_key_id

  tags = local.tags
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/ecs/${local.service_name}"
  retention_in_days = lookup(local.config.task, "log_retention_days", 30)
  kms_key_id        = local.kms_key_id

  tags = local.tags
}
