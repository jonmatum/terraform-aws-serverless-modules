# AWS Serverless Terraform Modules

[![Terraform Registry](https://img.shields.io/badge/Terraform-Registry-623CE4?logo=terraform)](https://registry.terraform.io/modules/jonmatum/serverless-modules/aws)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Educational Purpose](https://img.shields.io/badge/Purpose-Educational-yellow.svg)](https://github.com/jonmatum/terraform-aws-serverless-modules)

> **Note**: These modules are created for educational purposes to demonstrate AWS serverless architecture patterns and Terraform best practices. While following production-ready patterns, please review and test thoroughly before using in production environments.

Terraform modules for deploying serverless and container-based applications on AWS, following AWS Well-Architected Framework best practices.

## Well-Architected Framework

Built following [AWS Well-Architected Framework](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/docs/well-architected.md) best practices:

- **Security**: Encryption at rest/transit, least-privilege IAM, VPC endpoints, WAF
- **Reliability**: Multi-AZ deployment, auto-scaling, health checks, monitoring
- **Operational Excellence**: Container Insights, access logs, CloudWatch alarms
- **Performance**: Fargate compute, VPC endpoints, CloudFront CDN
- **Cost Optimization**: Fargate Spot, lifecycle policies, VPC endpoints

## Usage from Terraform Registry

```hcl
module "vpc" {
  source  = "jonmatum/serverless-modules/aws//modules/vpc"
  version = "~> 2.0"

  project_name = "my-app"
  cidr_block   = "10.0.0.0/16"
}

module "ecs" {
  source  = "jonmatum/serverless-modules/aws//modules/ecs"
  version = "~> 2.0"

  cluster_name = "my-cluster"
  vpc_id       = module.vpc.vpc_id
  subnet_ids   = module.vpc.private_subnet_ids
  # ...
}
```

## Modules

| Module | Description | Key Features |
|--------|-------------|--------------|
| [vpc](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/vpc) | Multi-AZ VPC | NAT gateways, VPC endpoints, flow logs |
| [ecr](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/ecr) | Container registry | Encryption, lifecycle policies, image scanning |
| [ecs](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/ecs) | Fargate service | Auto-scaling, Container Insights, Spot support |
| [lambda](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/lambda) | Lambda function | Container images, DLQ, retry policies, alarms |
| [alb](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/alb) | Application Load Balancer | Access logs, HTTPS, health checks |
| [dynamodb](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/dynamodb) | NoSQL database | Encryption, PITR, auto-scaling |
| [api-gateway](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/api-gateway) | HTTP API (v2) | Throttling, logging, X-Ray tracing |
| [api-gateway-v1](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/api-gateway-v1) | REST API | OpenAPI/Swagger support, VPC Link |
| [cloudfront-s3](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/cloudfront-s3) | CDN + Static hosting | SPA routing, OAC, custom domains |
| [waf](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/waf) | Web Application Firewall | Rate limiting, IP filtering, managed rules |
| [cloudwatch-alarms](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/cloudwatch-alarms) | Monitoring | CPU, memory, response time, error rates |

## Quick Start

### 1. Choose an Example

```bash
# Simple ECS application
cd examples/ecs-app

# Containerized Lambda function
cd examples/lambda-function

# Multi-service API Gateway
cd examples/api-gateway-multi-service

# CRUD API with DynamoDB + React
cd examples/crud-api-rest
```

### 2. Deploy

Each example includes a deploy script:

```bash
./deploy.sh
```

### 3. Test

```bash
terraform output
curl $(terraform output -raw api_endpoint)/health
```

### 4. Destroy

```bash
terraform destroy -auto-approve
```

## Examples

| Example | Description | Architecture | Components |
|---------|-------------|--------------|------------|
| [ecs-app](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/ecs-app) | Basic web app | ALB + ECS | VPC, ALB, ECS, ECR |
| [lambda-function](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/lambda-function) | Containerized Lambda | Lambda Function URL | Lambda, ECR, CloudWatch, SNS, SQS |
| [api-gateway-multi-service](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/api-gateway-multi-service) | Microservices | API Gateway + ECS | API Gateway, VPC Link, ECS, ALB |
| [crud-api-rest](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/crud-api-rest) | Full-stack CRUD | REST API + DynamoDB | API Gateway v1, ECS, DynamoDB, React |
| [crud-api-http](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/crud-api-http) | Optimized CRUD | HTTP API + DynamoDB | API Gateway v2, ECS, DynamoDB, React |
| [mcp-agent-runtime](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/mcp-agent-runtime) | MCP Server | ECS + Agent Gateway | ECS, ALB, MCP Protocol |
| [rest-api-service](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/rest-api-service) | Private API | REST API + VPC Link | API Gateway v1, VPC Link, ECS |
| [openapi-http-api](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/openapi-http-api) | Modern API | HTTP API + OpenAPI | API Gateway v2, OpenAPI 3.0, ECS |
| [openapi-rest-api](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/openapi-rest-api) | Traditional API | REST API + Swagger | API Gateway v1, Swagger 2.0, ECS |

### Architecture Patterns

**ECS with ALB:**
```
Client → Application Load Balancer → ECS Tasks (1-N) → ECR Repository
```

**API Gateway with VPC Link:**
```
Client → API Gateway → VPC Link → Private ALB → ECS Tasks
```

**CRUD API Pattern:**
```
Client → API Gateway → ECS Fargate → DynamoDB
Client → CloudFront → S3 Static Site
```

## Key Features

### Idempotent Deployments
```bash
terraform apply && terraform destroy && terraform apply  # Works!
```

All modules support idempotent deployments with proper dependency management.

### Auto-Scaling
```hcl
module "ecs" {
  source = "./modules/ecs"

  enable_autoscaling       = true
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 10
  autoscaling_target_cpu   = 70
  autoscaling_target_memory = 80
}
```

### Cost Optimization

#### Development Environment (~$70-90/month)
```hcl
module "vpc" {
  source = "./modules/vpc"

  single_nat_gateway = true  # Single NAT instead of Multi-AZ
}

module "ecs" {
  source = "./modules/ecs"

  enable_fargate_spot = true  # Use Spot pricing
  desired_count       = 1     # Minimal capacity
}
```

#### Production Environment (~$200-400/month)
```hcl
module "vpc" {
  source = "./modules/vpc"

  single_nat_gateway   = false  # Multi-AZ NAT
  enable_vpc_endpoints = true   # Reduce NAT costs
}

module "ecs" {
  source = "./modules/ecs"

  enable_fargate_spot      = false
  enable_autoscaling       = true
  autoscaling_min_capacity = 2
  autoscaling_max_capacity = 10
}
```

### Security

- **Encryption**: At rest (ECR, DynamoDB, S3) and in transit (TLS)
- **Secrets Management**: AWS Secrets Manager integration
- **IAM**: Least-privilege policies with scoped permissions
- **Network**: VPC endpoints, private subnets, security groups
- **WAF**: Rate limiting, IP filtering, managed rule sets

### Monitoring

Built-in CloudWatch alarms for:
- CPU/Memory utilization (ECS tasks)
- ALB response time and error rates
- Unhealthy target counts
- API Gateway 4XX/5XX errors
- DynamoDB throttling

## Cost Estimates

| Environment | Monthly Cost | Configuration |
|-------------|--------------|---------------|
| **Development** | $70-90 | Single NAT, Fargate Spot, 1 task, minimal capacity |
| **Staging** | $150-200 | Single NAT, On-Demand, 2 tasks, moderate capacity |
| **Production** | $200-400 | Multi-AZ NAT, On-Demand, Auto-scaling 2-10 tasks |

**Cost Breakdown** (Production):
- NAT Gateways (2x): ~$65/month
- Fargate (2-10 tasks): ~$50-200/month
- ALB: ~$20/month
- DynamoDB (on-demand): Variable
- Data transfer: Variable

## Secrets Management

```hcl
module "ecs" {
  source = "./modules/ecs"

  secrets = [
    {
      name      = "DATABASE_PASSWORD"
      valueFrom = "arn:aws:secretsmanager:us-east-1:123456789012:secret:db-password"
    },
    {
      name      = "API_KEY"
      valueFrom = "arn:aws:secretsmanager:us-east-1:123456789012:secret:api-key"
    }
  ]
}
```

## Testing

```bash
# Test all modules
./scripts/test-modules.sh

# Test specific example
./scripts/test-idempotency.sh api-gateway-multi-service

# Validate Terraform
terraform fmt -check -recursive
terraform validate
```

## Development Setup

### Prerequisites

- Terraform >= 1.0
- AWS CLI configured
- Docker (for examples)
- pre-commit (optional but recommended)

### Install pre-commit hooks

```bash
pip install pre-commit
pre-commit install
```

This will automatically:
- Format Terraform code (`terraform fmt`)
- Generate module documentation (`terraform-docs`)
- Validate Terraform syntax (`terraform validate`)
- Run linting checks (`tflint`)
- Check for common issues (trailing whitespace, large files, etc.)

### Manual Documentation Update

```bash
# Update all module and example documentation
pre-commit run terraform_docs --all-files

# Update specific module
cd modules/vpc
terraform-docs markdown table --output-file README.md --output-mode inject .
```

The pre-commit hooks ensure that all Terraform documentation (inputs, outputs, providers, requirements) is automatically generated and kept up to date. See [CONTRIBUTING.md](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/CONTRIBUTING.md) for detailed development guidelines.

## Documentation

- [Well-Architected Framework](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/docs/well-architected.md) - Architecture details and best practices
- [Module Documentation](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules) - Individual module README files
- [Example Guides](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples) - Step-by-step deployment guides

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run pre-commit hooks: `pre-commit run --all-files`
5. Test your changes: `./scripts/test-modules.sh`
6. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) file for details
