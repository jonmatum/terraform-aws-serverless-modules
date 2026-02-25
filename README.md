# AWS ECS Terraform Modules

Production-ready, Well-Architected Terraform modules for deploying containerized applications on AWS ECS.

## 🏗️ Architecture

Built following [AWS Well-Architected Framework](./WELL_ARCHITECTED.md) best practices.

## 📦 Modules

- **vpc** - Multi-AZ VPC with NAT gateways and VPC endpoints
- **ecr** - Container registry with encryption and lifecycle policies
- **ecs** - Fargate service with auto-scaling and Container Insights
- **alb** - Application Load Balancer with access logs and HTTPS
- **api-gateway** - HTTP API (v2) with VPC Link integration
- **api-gateway-v1** - REST API (v1) with VPC Link integration
- **cloudwatch-alarms** - Monitoring and alerting
- **waf** - Web Application Firewall
- **cloudfront-s3** - CloudFront with S3 origin
- **dynamodb** - DynamoDB tables

## 🚀 Quick Start

```bash
cd examples/api-gateway-multi-service
./deploy.sh
```

## 📚 Examples

- **ecs-app** - Basic ECS application with ALB
- **api-gateway-multi-service** - Multiple services behind API Gateway
- **rest-api-service** - REST API with VPC Link
- **openapi-http-api** - OpenAPI-based HTTP API
- **openapi-rest-api** - OpenAPI-based REST API

## 🔧 Development

### Pre-commit Hooks

This repository uses pre-commit hooks to automatically format and validate Terraform code. See [PRE_COMMIT.md](./PRE_COMMIT.md) for setup instructions.

```bash
# Install pre-commit
brew install pre-commit terraform-docs tflint

# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

## 📖 Documentation

- [Well-Architected Implementation](./WELL_ARCHITECTED.md)
- [Pre-commit Setup](./PRE_COMMIT.md)
- [Module Documentation](./modules/)

## 🏷️ Module Releases

Each module is released independently with semantic versioning:

```hcl
module "vpc" {
  source = "github.com/jonmatum/aws-ecs-poc//modules/vpc?ref=modules/vpc/v0.1.0"
  # ...
}
```

## 📄 License

MIT
