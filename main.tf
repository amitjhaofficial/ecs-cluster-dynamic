provider "aws" {
  region = var.region
}

resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = {
    Name = "ecs-task-execution-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_exec_attach" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = var.ecs_task_execution_policy_arn
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/containers"
  retention_in_days = 7
}

resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group" "ecs_sg" {
  for_each = local.clusters

  name   = "ecs-sg-${each.key}"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-task-sg-${each.key}"
  }
}

resource "aws_ecs_cluster" "ecs_clusters" {
  for_each = local.clusters
  name     = each.key
}


resource "aws_lb" "albs" {
  for_each           = local.albs
  name               = each.key
  internal           = each.value.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = each.value.internal ? var.private_subnet_ids : var.public_subnet_ids

  tags = {
    Name = each.key
  }
}

resource "aws_lb_listener" "http" {
  for_each          = aws_lb.albs
  load_balancer_arn = each.value.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "No route matched"
      status_code  = "404"
    }
  }
}

resource "aws_lb_target_group" "tg" {
  for_each = local.services_map

  name        = "${each.key}-tg"
  port        = each.value.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_ecs_task_definition" "tasks" {
  for_each               = local.services_map
  family                 = each.key
  requires_compatibilities = ["FARGATE"]
  network_mode           = "awsvpc"
  cpu                    = each.value.cpu
  memory                 = each.value.memory
  execution_role_arn     = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name      = each.key,
      image     = local.ecr_image_uris[each.key],
      portMappings = [{
        containerPort = each.value.container_port,
        protocol      = "tcp"
      }],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name,
          awslogs-region        = var.region,
          awslogs-stream-prefix = each.key
        }
      }
    }
  ])
}

resource "aws_ecs_service" "nginx_service" {
  for_each = local.service_map

  name            = each.key
  cluster         = aws_ecs_cluster.ecs_clusters[each.value.cluster].id
  task_definition = aws_ecs_task_definition.tasks[each.key].arn
  launch_type     = "FARGATE"
  desired_count   = each.value.desired_count

  network_configuration {
    subnets          = local.albs[each.value.alb].internal ? var.private_subnet_ids : var.public_subnet_ids
    assign_public_ip = !local.albs[each.value.alb].internal
    security_groups  = [aws_security_group.ecs_sg[each.value.cluster].id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg[each.key].arn
    container_name   = each.key
    container_port   = each.value.container_port
  }

  depends_on = [
    aws_lb_listener_rule.routing
  ]
}


resource "aws_lb_listener_rule" "routing" {
  for_each     = local.services_map
  listener_arn = aws_lb_listener.http[local.service_map[each.key].alb].arn
  priority     = 100 + index(keys(local.services_map), each.key)

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg[each.key].arn
  }

  dynamic "condition" {
    for_each = local.service_map[each.key].host != null ? [1] : []
    content {
      host_header {
        values = [local.service_map[each.key].host]
      }
    }
  }

  dynamic "condition" {
    for_each = local.service_map[each.key].host == null ? [1] : []
    content {
      path_pattern {
        values = [local.service_map[each.key].path]
      }
    }
  }
}
