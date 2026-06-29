variable "aws_region" {
  default = "us-east-1"
}

variable "aws_account_id" {
  default = "880247664530"
}

variable "app_name" {
  default = "finance-app"
}

locals {
  project_tag = "cloudgenai"
  managed_by_tag = "terraform"
}

provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "selected" {
  default = true
}

resource "aws_security_group" "ecs_task" {
  name        = "${var.app_name}-ecs-task-sg"
  vpc_id      = data.aws_vpc.selected.id
  tags = {
    Project     = local.project_tag
    ManagedBy   = local.managed_by_tag
  }
}

resource "aws_security_group" "api_gateway" {
  name        = "${var.app_name}-api-gateway-sg"
  vpc_id      = data.aws_vpc.selected.id
  tags = {
    Project     = local.project_tag
    ManagedBy   = local.managed_by_tag
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "${var.app_name}-cluster"
  tags = {
    Project     = local.project_tag
    ManagedBy   = local.managed_by_tag
  }
}

resource "aws_ecs_task_definition" "task" {
  family                   = "${var.app_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name  = "${var.app_name}-container"
      image = "amazon/amazon-ecs-sample"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort = 80
        }
      ]
    }
  ])

  tags = {
    Project     = local.project_tag
    ManagedBy   = local.managed_by_tag
  }
}

resource "aws_ecs_service" "service" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets = [data.aws_vpc.selected.default_subnet_ids[0]]
    security_groups = [aws_security_group.ecs_task.id]
  }
  tags = {
    Project     = local.project_tag
    ManagedBy   = local.managed_by_tag
  }
}

resource "aws_cognito_user_pool" "user_pool" {
  name = "${var.app_name}-user-pool"

  tags = {
    Project     = local.project_tag
    ManagedBy   = local.managed_by_tag
  }
}

resource "aws_cognito_user_pool_client" "user_pool_client" {
  user_pool_id = aws_cognito_user_pool.user_pool.id
  generate_secret = true

  tags = {
    Project     = local.project_tag
    ManagedBy   = local.managed_by_tag
  }
}

resource "aws_apigatewayv2_api" "api" {
  name        = "${var.app_name}-api"
  protocol_type = "HTTP"
  tags = {
    Project     = local.project_tag
    ManagedBy   = local.managed_by_tag
  }
}

resource "aws_apigatewayv2_authorizer" "cognito_authorizer" {
  api_id    = aws_apigatewayv2_api.api.id
  identity_source = ["$request.header.Authorization"]
  type      = "JWT"
  jwt_configuration {
    audience = [aws_cognito_user_pool_client.user_pool_client.client_id]
    issuer   = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.user_pool.id}"
  }
  tags = {
    Project     = local.project_tag
    ManagedBy   = local.managed_by_tag
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.app_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Project     = local.project_tag
    ManagedBy   = local.managed_by_tag
  }
}