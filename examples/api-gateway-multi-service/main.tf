terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source = "../../modules/vpc"

  name               = "${var.project_name}-vpc"
  cidr               = "10.0.0.0/16"
  azs                = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true # Set to false for production

  tags = var.tags
}

# FastAPI Service
module "ecr_fastapi" {
  source = "../../modules/ecr"

  repository_name = "${var.project_name}-fastapi"
  tags            = var.tags
}

module "alb_fastapi" {
  source = "../../modules/alb"

  name              = "${var.project_name}-fastapi-alb"
  internal          = true
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  target_port       = 8000
  health_check_path = "/"

  tags = var.tags
}

module "ecs_fastapi" {
  source = "../../modules/ecs"

  cluster_name       = "${var.project_name}-cluster"
  task_family        = "${var.project_name}-fastapi"
  service_name       = "${var.project_name}-fastapi-service"
  container_name     = "fastapi"
  container_image    = "${module.ecr_fastapi.repository_url}:latest"
  container_port     = 8000
  execution_role_arn = aws_iam_role.ecs_execution.arn
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.ecs_tasks.id]
  assign_public_ip   = false
  log_group_name     = aws_cloudwatch_log_group.fastapi.name
  aws_region         = var.aws_region
  target_group_arn   = module.alb_fastapi.target_group_arn

  tags = var.tags
}

# MCP Service
module "ecr_mcp" {
  source = "../../modules/ecr"

  repository_name = "${var.project_name}-mcp"
  tags            = var.tags
}

module "alb_mcp" {
  source = "../../modules/alb"

  name              = "${var.project_name}-mcp-alb"
  internal          = true
  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.private_subnet_ids
  target_port       = 3000
  health_check_path = "/"

  tags = var.tags
}

module "ecs_mcp" {
  source = "../../modules/ecs"

  cluster_name       = "${var.project_name}-cluster"
  task_family        = "${var.project_name}-mcp"
  service_name       = "${var.project_name}-mcp-service"
  container_name     = "mcp"
  container_image    = "${module.ecr_mcp.repository_url}:latest"
  container_port     = 3000
  execution_role_arn = aws_iam_role.ecs_execution.arn
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.ecs_tasks.id]
  assign_public_ip   = false
  log_group_name     = aws_cloudwatch_log_group.mcp.name
  aws_region         = var.aws_region
  target_group_arn   = module.alb_mcp.target_group_arn

  tags = var.tags
}

# API Gateway
module "api_gateway" {
  source = "../../modules/api-gateway"

  name                        = "${var.project_name}-api"
  vpc_link_subnet_ids         = module.vpc.private_subnet_ids
  vpc_link_security_group_ids = [aws_security_group.vpc_link.id]

  integrations = {
    fastapi = {
      method          = "ANY"
      route_key       = "ANY /api/fastapi/{proxy+}"
      connection_type = "VPC_LINK"
      uri             = module.alb_fastapi.listener_arn
    }
    mcp = {
      method          = "ANY"
      route_key       = "ANY /api/mcp/{proxy+}"
      connection_type = "VPC_LINK"
      uri             = module.alb_mcp.listener_arn
    }
  }

  tags = var.tags

  depends_on = [module.alb_fastapi, module.alb_mcp]
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "fastapi" {
  name              = "/ecs/${var.project_name}-fastapi"
  retention_in_days = 30
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "mcp" {
  name              = "/ecs/${var.project_name}-mcp"
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
        Resource = [
          "${aws_cloudwatch_log_group.fastapi.arn}:*",
          "${aws_cloudwatch_log_group.mcp.arn}:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = [
          module.ecr_fastapi.repository_arn,
          module.ecr_mcp.repository_arn
        ]
      }
    ]
  })
}

# Security Groups
resource "aws_security_group_rule" "vpc_link_to_fastapi_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.vpc_link.id
  security_group_id        = module.alb_fastapi.alb_security_group_id
}

resource "aws_security_group_rule" "vpc_link_to_mcp_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.vpc_link.id
  security_group_id        = module.alb_mcp.alb_security_group_id
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasks"
  description = "Security group for ECS tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [module.alb_fastapi.alb_security_group_id]
    description     = "Allow traffic from FastAPI ALB"
  }

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [module.alb_mcp.alb_security_group_id]
    description     = "Allow traffic from MCP ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = var.tags
}

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

  tags = var.tags
}
