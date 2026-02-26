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

module "vpc" {
  source = "../../../modules/vpc"

  name               = "${var.app_name}-vpc"
  cidr               = "10.0.0.0/16"
  azs                = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = var.tags
}

module "alb" {
  source = "../../../modules/alb"

  name                   = "${var.app_name}-alb"
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.vpc.public_subnet_ids
  target_port            = var.container_port
  health_check_path      = "/health"
  enable_https           = var.enable_https
  certificate_arn        = var.certificate_arn
  redirect_http_to_https = var.enable_https

  tags = var.tags
}

module "ecr" {
  source = "../../../modules/ecr"

  repository_name      = var.app_name
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true

  tags = var.tags
}

module "ecs" {
  source = "../../../modules/ecs"

  cluster_name              = "${var.app_name}-cluster"
  task_family               = var.app_name
  service_name              = "${var.app_name}-service"
  container_name            = var.app_name
  container_image           = "${module.ecr.repository_url}:${var.image_tag}"
  container_port            = var.container_port
  cpu                       = var.cpu
  memory                    = var.memory
  desired_count             = var.desired_count
  execution_role_arn        = aws_iam_role.ecs_execution.arn
  subnet_ids                = module.vpc.private_subnet_ids
  security_group_ids        = [aws_security_group.ecs_tasks.id]
  assign_public_ip          = false
  target_group_arn          = module.alb.target_group_arn
  log_group_name            = aws_cloudwatch_log_group.this.name
  aws_region                = var.aws_region
  environment_variables     = var.environment_variables
  enable_autoscaling        = var.enable_autoscaling
  autoscaling_min_capacity  = var.autoscaling_min_capacity
  autoscaling_max_capacity  = var.autoscaling_max_capacity
  enable_container_insights = true

  tags = var.tags
}
