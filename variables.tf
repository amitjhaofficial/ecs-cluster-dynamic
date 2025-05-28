variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default = "us-east-1"
}

variable "vpc_id" {
  description = "VPC ID in which resources will be created"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "aws_account_id" {
  description = "Your AWS account ID"
  type        = string
}

variable "project_name_prefix" {
  description = "Prefix for ECR repo and other resources (e.g., app name)"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, prod)"
  type        = string
}

variable "ecs_task_execution_policy_arn" {
  description = "IAM policy ARN for ECS task execution"
  type        = string
}

variable "domain_name" {
  description = "Base domain used for host-based routing"
  type        = string
}

variable "services_config" {
  description = "CPU, memory, and port configs per service (optional override)"
  type = map(object({
    cpu    = string
    memory = string
    port   = number
  }))
}

variable "ecs_services" {
  description = "List of ECS services"
  type = list(object({
    name           = string
    image          = optional(string)
    cpu            = string
    memory         = string
    container_port = number
    desired_count  = number
    autoscale_min  = number
    autoscale_max  = number
    priority       = number
    path           = optional(string)
    host           = optional(string)
    cluster        = string
    alb            = string
  }))
}
