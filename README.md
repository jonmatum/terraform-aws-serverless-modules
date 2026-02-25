# AWS ECS Terraform Modules

Production-ready, Well-Architected Terraform modules for deploying containerized applications on AWS ECS.

## 🏗️ Architecture

Built following [AWS Well-Architected Framework](./WELL_ARCHITECTED.md) best practices:

- ✅ **Security**: Encryption, least-privilege IAM, VPC endpoints, secrets management
- ✅ **Reliability**: Multi-AZ, auto-scaling, health checks, monitoring
- ✅ **Operational Excellence**: Container Insights, access logs, CloudWatch alarms
- ✅ **Performance**: Fargate, VPC endpoints, connection draining
- ✅ **Cost Optimization**: Fargate Spot, lifecycle policies, VPC endpoints
- ✅ **Sustainability**: Auto-scaling, right-sizing, efficient networking

## 📦 Modules

- **vpc** - Multi-AZ VPC with NAT gateways and VPC endpoints
- **ecr** - Container registry with encryption and lifecycle policies
- **ecs** - Fargate service with auto-scaling and Container Insights
- **alb** - Application Load Balancer with access logs and HTTPS
- **api-gateway** - HTTP API with VPC Link integration
- **api-gateway-v1** - REST API with VPC Link integration
- **cloudwatch-alarms** - Monitoring and alerting

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

## 📖 Documentation

- [Well-Architected Implementation](./WELL_ARCHITECTED.md) - Detailed architecture and best practices
- [Module Documentation](./modules/) - Individual module documentation

## 🔧 Features

### Security
- ECR encryption at rest (AES256/KMS)
- Secrets Manager integration
- Scoped IAM policies
- VPC endpoints for AWS services
- Security groups with specific ports

### Reliability
- Multi-AZ deployment
- ECS auto-scaling (CPU/memory)
- Health checks and grace periods
- CloudWatch alarms
- Connection draining

### Cost Optimization
- Fargate Spot support (up to 70% savings)
- VPC endpoints (reduce NAT costs)
- ECR lifecycle policies
- S3 log lifecycle management
- Right-sized defaults

## 🏷️ Tagging Strategy

All resources support standard cost allocation tags:

```hcl
tags = {
  Environment = "production"
  Project     = "my-app"
  ManagedBy   = "terraform"
  CostCenter  = "engineering"
}
```

## 🔐 Secrets Management

```hcl
module "ecs" {
  source = "./modules/ecs"
  
  secrets = [
    {
      name      = "DATABASE_PASSWORD"
      valueFrom = "arn:aws:secretsmanager:region:account:secret:name"
    }
  ]
}
```

## 📊 Monitoring

Built-in CloudWatch alarms for:
- CPU utilization
- Memory utilization
- ALB response time
- Unhealthy targets
- 5XX errors

## 💰 Cost Optimization

### Development
```hcl
single_nat_gateway  = true   # Single NAT
enable_fargate_spot = true   # Use Spot instances
fargate_spot_weight = 70     # 70% Spot, 30% On-Demand
```

### Production
```hcl
single_nat_gateway  = false  # Multi-AZ NAT
enable_fargate_spot = false  # On-Demand only
enable_vpc_endpoints = true  # Reduce NAT costs
```

## 🤝 Contributing

Contributions welcome! Please ensure changes maintain Well-Architected compliance.

## 📄 License

MIT
