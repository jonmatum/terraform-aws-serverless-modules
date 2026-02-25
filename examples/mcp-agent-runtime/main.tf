terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.18.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
module "vpc" {
  source = "../../modules/vpc"

  name                 = "${var.project_name}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true # Dev only - use false for production
  enable_vpc_endpoints = true

  tags = var.tags
}

# ECR Repository
module "ecr" {
  source = "../../modules/ecr"

  repository_name      = "${var.project_name}-mcp"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  encryption_type      = "AES256"
  force_delete         = true

  lifecycle_policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 5 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 5
      }
      action = {
        type = "expire"
      }
    }]
  })

  tags = var.tags
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "mcp" {
  name              = "/ecs/${var.project_name}-mcp"
  retention_in_days = 30

  tags = var.tags
}

# ECS Execution Role
resource "aws_iam_role" "ecs_execution" {
  name = "${var.project_name}-ecs-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy" "ecs_execution_custom" {
  name = "${var.project_name}-ecs-execution-custom"
  role = aws_iam_role.ecs_execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = module.ecr.repository_arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.mcp.arn}:*"
      }
    ]
  })
}

# ECS Task Role (for application permissions)
resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-ecs-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

# Security Group for ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasks"
  description = "Security group for ECS tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Traffic from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [module.alb.alb_security_group_id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-ecs-tasks"
  })
}

# IAM Role for AgentCore Gateway
resource "aws_iam_role" "gateway" {
  name = "${var.project_name}-gateway-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "bedrock-agentcore.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "gateway" {
  name = "${var.project_name}-gateway-policy"
  role = aws_iam_role.gateway.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:log-group:/aws/bedrock-agentcore/*"
      }
    ]
  })
}

# AgentCore Gateway
resource "aws_bedrockagentcore_gateway" "mcp" {
  name        = "${var.project_name}-gateway"
  description = "AgentCore Gateway for MCP Server"
  role_arn    = aws_iam_role.gateway.arn

  authorizer_type = "AWS_IAM"
  protocol_type   = "MCP"

  protocol_configuration {
    mcp {
      instructions       = "Gateway for MCP server running on ECS"
      search_type        = "HYBRID"
      supported_versions = ["2025-03-26"]
    }
  }

  tags = var.tags
}

# AgentCore Gateway Target (MCP Server on ALB)
resource "aws_bedrockagentcore_gateway_target" "mcp_server" {
  gateway_identifier = aws_bedrockagentcore_gateway.mcp.gateway_id
  name               = "${var.project_name}-mcp-server"
  description        = "MCP Server running on ECS Fargate"

  target_configuration {
    mcp {
      endpoint = "http://${module.alb.alb_dns_name}"
    }
  }

  tags = var.tags

  depends_on = [module.alb, module.ecs]
}

# ALB
module "alb" {
  source = "../../modules/alb"

  name        = "${var.project_name}-alb"
  vpc_id      = module.vpc.vpc_id
  subnet_ids  = module.vpc.public_subnet_ids
  target_port = 3000

  health_check_path  = "/health"
  enable_access_logs = true

  tags = var.tags
}

# ECS Cluster and Service
module "ecs" {
  source = "../../modules/ecs"

  cluster_name       = "${var.project_name}-cluster"
  task_family        = "${var.project_name}-mcp-task"
  service_name       = "${var.project_name}-mcp-service"
  container_name     = "mcp-server"
  container_image    = "${module.ecr.repository_url}:latest"
  container_port     = 3000
  cpu                = "256"
  memory             = "512"
  desired_count      = 1
  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn      = aws_iam_role.ecs_task.arn
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.ecs_tasks.id]
  target_group_arn   = module.alb.target_group_arn
  log_group_name     = aws_cloudwatch_log_group.mcp.name
  aws_region         = var.aws_region

  environment_variables = [
    {
      name  = "PORT"
      value = "3000"
    },
    {
      name  = "NODE_ENV"
      value = "production"
    },
    {
      name  = "AWS_REGION"
      value = var.aws_region
    }
  ]

  enable_autoscaling       = true
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 4

  enable_fargate_spot = true
  fargate_spot_weight = 50

  tags = var.tags
}

# API Gateway (Agent Gateway)
module "api_gateway" {
  source = "../../modules/api-gateway"

  name                        = "${var.project_name}-agent-gateway"
  vpc_link_subnet_ids         = module.vpc.private_subnet_ids
  vpc_link_security_group_ids = [aws_security_group.vpc_link.id]

  integrations = {
    health = {
      method          = "GET"
      route_key       = "GET /health"
      connection_type = "VPC_LINK"
      uri             = module.alb.listener_arn
    }
    tools_list = {
      method          = "POST"
      route_key       = "POST /mcp/tools/list"
      connection_type = "VPC_LINK"
      uri             = module.alb.listener_arn
    }
    tools_call = {
      method          = "POST"
      route_key       = "POST /mcp/tools/call"
      connection_type = "VPC_LINK"
      uri             = module.alb.listener_arn
    }
  }

  enable_access_logs   = true
  enable_xray_tracing  = true
  enable_throttling    = true
  throttle_burst_limit = 100
  throttle_rate_limit  = 50

  tags = var.tags

  depends_on = [module.alb]
}

# CloudWatch Alarms
module "cloudwatch_alarms" {
  source = "../../modules/cloudwatch-alarms"

  cluster_name = var.project_name
  service_name = module.ecs.service_name

  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix

  tags = var.tags
}
