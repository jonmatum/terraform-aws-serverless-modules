# VPC for ECS and private resources
module "vpc" {
  source = "../../../modules/vpc"

  name                 = "${var.project_name}-vpc"
  cidr                 = "10.0.0.0/16"
  azs                  = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets       = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = var.environment == "dev"
  enable_vpc_endpoints = true

  tags = var.tags
}

# ECR for ECS-based MCP server
module "ecr_ecs" {
  source = "../../../modules/ecr"

  repository_name      = "${var.project_name}-mcp-ecs"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  force_delete         = var.environment == "dev"

  tags = var.tags
}

# ECR for Lambda-based MCP server
module "ecr_lambda" {
  source = "../../../modules/ecr"

  repository_name      = "${var.project_name}-mcp-lambda"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  force_delete         = var.environment == "dev"

  tags = var.tags
}

# ALB for ECS MCP server
module "alb" {
  source = "../../../modules/alb"

  name               = "${var.project_name}-alb"
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.public_subnet_ids
  target_port        = 3000
  health_check_path  = "/health"
  enable_access_logs = true
  certificate_arn    = var.certificate_arn
  enable_https       = var.certificate_arn != ""

  tags = var.tags
}
