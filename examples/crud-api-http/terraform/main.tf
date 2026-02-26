terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
module "vpc" {
  source = "../../../modules/vpc"

  name               = "${var.project_name}-vpc"
  cidr               = "10.0.0.0/16"
  azs                = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = var.tags
}

# DynamoDB Table
module "dynamodb" {
  source = "../../../modules/dynamodb"

  table_name                    = "${var.project_name}-items"
  hash_key                      = "id"
  billing_mode                  = "PAY_PER_REQUEST"
  enable_point_in_time_recovery = true
  enable_encryption             = true

  tags = var.tags
}

# ECR Repository
module "ecr" {
  source = "../../../modules/ecr"

  repository_name = "${var.project_name}-api"
  tags            = var.tags
}

# ALB
module "alb" {
  source = "../../../modules/alb"

  name              = "${var.project_name}-alb"
  internal          = true
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  target_port       = 8000
  health_check_path = "/health"

  tags = var.tags
}

# ECS Service
module "ecs" {
  source = "../../../modules/ecs"

  cluster_name       = "${var.project_name}-cluster"
  task_family        = "${var.project_name}-api"
  service_name       = "${var.project_name}-api-service"
  container_name     = "api"
  container_image    = "${module.ecr.repository_url}:latest"
  container_port     = 8000
  execution_role_arn = aws_iam_role.ecs_execution.arn
  task_role_arn      = aws_iam_role.ecs_task.arn
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.ecs_tasks.id]
  assign_public_ip   = false
  target_group_arn   = module.alb.target_group_arn
  log_group_name     = aws_cloudwatch_log_group.api.name
  aws_region         = var.aws_region

  environment_variables = [
    {
      name  = "DYNAMODB_TABLE_NAME"
      value = module.dynamodb.table_name
    },
    {
      name  = "AWS_REGION"
      value = var.aws_region
    }
  ]

  tags = var.tags
}

# API Gateway HTTP API (v2) - Direct to ALB
module "api_gateway" {
  source = "../../../modules/api-gateway"

  name                        = "${var.project_name}-api"
  vpc_link_subnet_ids         = module.vpc.private_subnet_ids
  vpc_link_security_group_ids = [aws_security_group.vpc_link.id]

  integrations = {
    proxy = {
      method          = "ANY"
      route_key       = "ANY /{proxy+}"
      connection_type = "VPC_LINK"
      uri             = module.alb.listener_arn
    }
    root = {
      method          = "GET"
      route_key       = "GET /"
      connection_type = "VPC_LINK"
      uri             = module.alb.listener_arn
    }
  }

  enable_access_logs  = true
  enable_xray_tracing = true

  tags = var.tags

  depends_on = [module.alb]
}

# WAF (optional)
module "waf" {
  count  = var.enable_waf ? 1 : 0
  source = "../../../modules/waf"

  name         = "${var.project_name}-waf"
  scope        = "REGIONAL"
  resource_arn = module.api_gateway.stage_arn

  enable_rate_limiting    = true
  rate_limit              = 2000
  enable_ip_reputation    = true
  enable_known_bad_inputs = true

  tags = var.tags
}

# CloudFront + S3 for React App
module "cloudfront" {
  source = "../../../modules/cloudfront-s3"

  name           = "${var.project_name}-web"
  enable_logging = true

  tags = var.tags
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "api" {
  name              = "/ecs/${var.project_name}-api"
  retention_in_days = 30
  tags              = var.tags
}

# IAM Role for ECS Execution
resource "aws_iam_role" "ecs_execution" {
  name = "${var.project_name}-ecs-execution-role"

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
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.api.arn}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Role for ECS Task
resource "aws_iam_role" "ecs_task" {
  name = "${var.project_name}-ecs-task-role"

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

resource "aws_iam_role_policy" "ecs_task_dynamodb" {
  name = "${var.project_name}-ecs-task-dynamodb"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:DescribeTable",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = module.dynamodb.table_arn
      }
    ]
  })
}

# Security Group for ECS Tasks
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasks"
  description = "Security group for ECS tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [module.alb.alb_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-ecs-tasks"
  })
}

# Security Group for VPC Link
resource "aws_security_group" "vpc_link" {
  name        = "${var.project_name}-vpc-link"
  description = "Security group for API Gateway VPC Link"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-vpc-link"
  })
}

# Allow VPC Link to ALB
resource "aws_security_group_rule" "vpc_link_to_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.vpc_link.id
  security_group_id        = module.alb.alb_security_group_id
  description              = "Allow traffic from VPC Link to ALB"
}
