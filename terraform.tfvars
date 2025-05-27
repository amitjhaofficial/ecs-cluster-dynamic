region             = "eu-west-2"
vpc_id             = "vpc-0d8e866f73db7e7dd"

public_subnet_ids  = [
  "subnet-004d7b29c62d44e99",
  "subnet-0b34ffafb5589bc62"
]

private_subnet_ids = [
  "subnet-0ab13dd65be98c019",
  "subnet-086d864e41a626cd5"
]

aws_account_id      = "168126498686"
project_name_prefix = "tbr"
environment         = "dev"
domain_name         = "dev.theblackrise.com"

ecs_task_execution_policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

services_config = {
  events-service = {
    cpu    = "256"
    memory = "512"
    port   = 8080
  }
  network-service = {
    cpu    = "256"
    memory = "512"
    port   = 8080
  }
  email-service = {
    cpu    = "256"
    memory = "512"
    port   = 5001
  }
  user-profile-service = {
    cpu    = "256"
    memory = "512"
    port   = 8080
  }
  security-service = {
    cpu    = "256"
    memory = "512"
    port   = 8080
  }
  messaging-service = {
    cpu    = "256"
    memory = "512"
    port   = 8080
  }
  static-data-service = {
    cpu    = "256"
    memory = "512"
    port   = 8080
  }
  post-service = {
    cpu    = "256"
    memory = "512"
    port   = 8080
  }
  activity-service = {
    cpu    = "256"
    memory = "512"
    port   = 8080
  }
  client-portal = {
    cpu    = "256"
    memory = "512"
    port   = 80
  }
}

ecs_services = [
  {
    name           = "events-service"
    image          = "nginx:latest"
    cpu            = "256"
    memory         = "512"
    container_port = 8080
    desired_count  = 0
    autoscale_min  = 1
    autoscale_max  = 1
    priority       = 1
    path           = "/events-service"
    cluster        = "internal-cluster"
    alb            = "int-alb"
  },
  {
    name           = "network-service"
    image          = "nginx:latest"
    cpu            = "256"
    memory         = "512"
    container_port = 8080
    desired_count  = 1
    autoscale_min  = 1
    autoscale_max  = 1
    priority       = 2
    path           = "/network-service"
    cluster        = "internal-cluster"
    alb            = "int-alb"
  },
  {
    name           = "email-service"
    image          = "nginx:latest"
    cpu            = "256"
    memory         = "512"
    container_port = 5001
    desired_count  = 1
    autoscale_min  = 1
    autoscale_max  = 1
    priority       = 3
    path           = "/email-service"
    cluster        = "internal-cluster"
    alb            = "int-alb"
  },
  {
    name           = "user-profile-service"
    image          = "nginx:latest"
    cpu            = "256"
    memory         = "512"
    container_port = 8080
    desired_count  = 1
    autoscale_min  = 1
    autoscale_max  = 1
    priority       = 4
    path           = "/profile-service"
    cluster        = "internal-cluster"
    alb            = "int-alb"
  },
  {
    name           = "security-service"
    image          = "nginx:latest"
    cpu            = "256"
    memory         = "512"
    container_port = 8080
    desired_count  = 1
    autoscale_min  = 1
    autoscale_max  = 1
    priority       = 5
    path           = "/security-service"
    cluster        = "internal-cluster"
    alb            = "int-alb"
  },
  {
    name           = "messaging-service"
    image          = "nginx:latest"
    cpu            = "256"
    memory         = "512"
    container_port = 8080
    desired_count  = 0
    autoscale_min  = 1
    autoscale_max  = 1
    priority       = 6
    path           = "/message-service"
    cluster        = "internal-cluster"
    alb            = "int-alb"
  },
  {
    name           = "static-data-service"
    image          = "nginx:latest"
    cpu            = "256"
    memory         = "512"
    container_port = 8080
    desired_count  = 1
    autoscale_min  = 1
    autoscale_max  = 1
    priority       = 7
    path           = "/static-data-service"
    cluster        = "internal-cluster"
    alb            = "int-alb"
  },
  {
    name           = "post-service"
    image          = "nginx:latest"
    cpu            = "256"
    memory         = "512"
    container_port = 8080
    desired_count  = 0
    autoscale_min  = 1
    autoscale_max  = 1
    priority       = 8
    path           = "/post-service"
    cluster        = "internal-cluster"
    alb            = "int-alb"
  },
  {
    name           = "activity-service"
    image          = "nginx:latest"
    cpu            = "256"
    memory         = "512"
    container_port = 8080
    desired_count  = 0
    autoscale_min  = 1
    autoscale_max  = 1
    priority       = 9
    path           = "/activity-service"
    cluster        = "internal-cluster"
    alb            = "int-alb"
  },
  {
    name           = "client-portal"
    image          = "nginx:latest"
    cpu            = "256"
    memory         = "512"
    container_port = 80
    desired_count  = 1
    autoscale_min  = 1
    autoscale_max  = 1
    priority       = 10
    host           = "dev.theblackrise.com"
    cluster        = "external-cluster"
    alb            = "external-alb"
  }
]
