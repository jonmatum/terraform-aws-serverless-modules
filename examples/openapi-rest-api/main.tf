terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Generate OpenAPI spec from FastAPI using Docker and convert to Swagger 2.0
resource "null_resource" "generate_openapi" {
  triggers = {
    app_hash = filemd5("${path.module}/app.py")
  }

  provisioner "local-exec" {
    command = <<-EOT
      cd ${path.module}
      docker run --rm -v $(pwd):/app -w /app python:3.11-slim sh -c "
        pip install -q fastapi uvicorn && \
        python3 -c \"
import json
from app import app

spec = app.openapi()

# Helper to convert schema references
def convert_refs(obj):
    if isinstance(obj, dict):
        return {k: convert_refs(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [convert_refs(item) for item in obj]
    elif isinstance(obj, str) and '#/components/schemas/' in obj:
        return obj.replace('#/components/schemas/', '#/definitions/')
    return obj

swagger = {
    'swagger': '2.0',
    'info': spec['info'],
    'host': '${aws_lb.nlb.dns_name}',
    'basePath': '/',
    'schemes': ['http'],
    'paths': {},
    'definitions': convert_refs(spec.get('components', {}).get('schemas', {}))
}

for path, methods in spec.get('paths', {}).items():
    swagger['paths'][path] = {}
    for method, details in methods.items():
        if method in ['get', 'post', 'put', 'delete', 'patch']:
            swagger['paths'][path][method] = {
                'summary': details.get('summary', ''),
                'description': details.get('description', ''),
                'produces': ['application/json'],
                'responses': {},
                'x-amazon-apigateway-integration': {
                    'type': 'http_proxy',
                    'httpMethod': method.upper(),
                    'uri': 'http://' + '\$' + '{stageVariables.nlb_dns}' + path,
                    'connectionType': 'VPC_LINK',
                    'connectionId': '\$' + '{stageVariables.vpc_link_id}',
                    'responses': {
                        'default': {
                            'statusCode': '200'
                        }
                    }
                }
            }
            # Convert responses
            for status, response in details.get('responses', {}).items():
                swagger['paths'][path][method]['responses'][status] = {
                    'description': response.get('description', '')
                }
                if 'content' in response and 'application/json' in response['content']:
                    schema = convert_refs(response['content']['application/json'].get('schema', {}))
                    swagger['paths'][path][method]['responses'][status]['schema'] = schema
            
            if 'requestBody' in details:
                swagger['paths'][path][method]['consumes'] = ['application/json']
                schema = convert_refs(details['requestBody']['content']['application/json']['schema'])
                swagger['paths'][path][method]['parameters'] = [{
                    'in': 'body',
                    'name': 'body',
                    'required': True,
                    'schema': schema
                }]

with open('openapi.json', 'w') as f:
    json.dump(swagger, f, indent=2)
        \"
      "
    EOT
  }

  depends_on = [aws_lb.nlb, aws_api_gateway_vpc_link.this]
}

data "local_file" "openapi_spec" {
  filename   = "${path.module}/openapi.json"
  depends_on = [null_resource.generate_openapi]
}

module "vpc" {
  source = "../../modules/vpc"

  name               = "${var.project_name}-vpc"
  cidr               = "10.0.0.0/16"
  azs                = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets     = ["10.0.101.0/24", "10.0.102.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true

  tags = var.tags
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name = var.project_name
  tags            = var.tags
}

module "ecs" {
  source = "../../modules/ecs"

  cluster_name       = "${var.project_name}-cluster"
  task_family        = var.project_name
  service_name       = "${var.project_name}-service"
  container_name     = "app"
  container_image    = "${module.ecr.repository_url}:latest"
  container_port     = 8000
  execution_role_arn = aws_iam_role.ecs_execution.arn
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.ecs_tasks.id]
  assign_public_ip   = false
  target_group_arn   = aws_lb_target_group.this.arn
  log_group_name     = aws_cloudwatch_log_group.this.name
  aws_region         = var.aws_region

  tags = var.tags
}

# Network Load Balancer for VPC Link
resource "aws_lb" "nlb" {
  name               = "${var.project_name}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = module.vpc.private_subnet_ids

  tags = var.tags
}

resource "aws_lb_target_group" "this" {
  name        = "${var.project_name}-tg"
  port        = 8000
  protocol    = "TCP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    protocol            = "HTTP"
    path                = "/health"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
  }

  tags = var.tags
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# API Gateway REST API with OpenAPI spec
resource "aws_api_gateway_vpc_link" "this" {
  name        = "${var.project_name}-vpc-link"
  target_arns = [aws_lb.nlb.arn]

  tags = var.tags
}

resource "aws_api_gateway_rest_api" "this" {
  name = var.project_name
  body = data.local_file.openapi_spec.content

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags

  depends_on = [null_resource.generate_openapi]
}

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(data.local_file.openapi_spec.content)
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = "prod"

  variables = {
    nlb_dns     = aws_lb.nlb.dns_name
    vpc_link_id = aws_api_gateway_vpc_link.this.id
  }

  tags = var.tags
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
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
        Resource = "${aws_cloudwatch_log_group.this.arn}:*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
}

# Security Groups
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasks"
  description = "Security group for ECS tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
