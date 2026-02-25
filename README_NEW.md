# AWS ECS Terraform Modules

Production-ready, Well-Architected Terraform modules for deploying containerized applications on AWS ECS.

## 🏗️ Architecture

Built following [AWS Well-Architected Framework](./WELL_ARCHITECTED.md) best practices:

- ✅ **Security**: Encryption, least-privilege IAM, VPC endpoints, WAF
- ✅ **Reliability**: Multi-AZ, auto-scaling, health checks, monitoring
- ✅ **Operational Excellence**: Container Insights, access logs, alarms
- ✅ **Performance**: Fargate, VPC endpoints, CloudFront CDN
- ✅ **Cost Optimization**: Fargate Spot, lifecycle policies, VPC endpoints

## 📦 Modules

| Module | Description | Key Features |
|--------|-------------|--------------|
| **vpc** | Multi-AZ VPC | NAT gateways, VPC endpoints |
| **ecr** | Container registry | Encryption, lifecycle policies, scanning |
| **ecs** | Fargate service | Auto-scaling, Container Insights |
| **alb** | Application Load Balancer | Access logs, HTTPS, health checks |
| **dynamodb** | NoSQL database | Encryption, PITR, auto-scaling |
| **api-gateway** | HTTP API (v2) | Throttling, logging, X-Ray |
| **api-gateway-v1** | REST API | OpenAPI/Swagger support |
| **cloudfront-s3** | CDN + Static hosting | SPA routing, OAC |
| **waf** | Web Application Firewall | Rate limiting, IP filtering |
| **cloudwatch-alarms** | Monitoring | CPU, memory, response time |

## 🚀 Quick Start

### 1. Choose an Example

```bash
# Simple ECS application
cd examples/ecs-app

# Multi-service API Gateway
cd examples/api-gateway-multi-service

# CRUD API with DynamoDB + React
cd examples/crud-api-rest
```

### 2. Deploy

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

## 📚 Examples

| Example | Description | Components |
|---------|-------------|------------|
| [ecs-app](./examples/ecs-app/) | Basic web app | ECS + ALB |
| [api-gateway-multi-service](./examples/api-gateway-multi-service/) | Microservices | API Gateway + ECS + ALB |
| [crud-api-rest](./examples/crud-api-rest/) | Full-stack CRUD | FastAPI + DynamoDB + React |
| [rest-api-service](./examples/rest-api-service/) | Private API | REST API + VPC Link |
| [openapi-http-api](./examples/openapi-http-api/) | Modern API | HTTP API + OpenAPI |
| [openapi-rest-api](./examples/openapi-rest-api/) | Traditional API | REST API + Swagger |

## 🔧 Key Features

### Idempotent Deployments
```bash
terraform apply && terraform destroy && terraform apply  # Works!
```

### Auto-Scaling
```hcl
enable_autoscaling       = true
autoscaling_min_capacity = 1
autoscaling_max_capacity = 10
```

### Cost Optimization
```hcl
# Dev: ~$70/month
single_nat_gateway  = true
enable_fargate_spot = true

# Prod: ~$200/month
single_nat_gateway  = false
enable_vpc_endpoints = true
```

### Security
- Encryption at rest (ECR, DynamoDB, S3)
- Secrets Manager integration
- Scoped IAM policies
- VPC endpoints
- WAF protection

## 📊 Cost Estimates

| Environment | Monthly Cost | Key Resources |
|-------------|--------------|---------------|
| **Development** | $70-90 | Single NAT, Fargate Spot |
| **Production** | $200-400 | Multi-AZ NAT, Auto-scaling |

## 🔐 Secrets Management

```hcl
module "ecs" {
  source = "./modules/ecs"
  
  secrets = [{
    name      = "DATABASE_PASSWORD"
    valueFrom = "arn:aws:secretsmanager:..."
  }]
}
```

## 📈 Monitoring

Built-in CloudWatch alarms:
- CPU/Memory utilization
- ALB response time
- Unhealthy targets
- 5XX errors

## 🧪 Testing

```bash
# Test all modules
./test-modules.sh

# Test idempotency
./test-idempotency.sh api-gateway-multi-service
```

## 📖 Documentation

- [WELL_ARCHITECTED.md](./WELL_ARCHITECTED.md) - Architecture details
- [modules/*/README.md](./modules/) - Module documentation
- [examples/*/README.md](./examples/) - Example guides

## 🤝 Contributing

```bash
pre-commit run --all-files
./test-modules.sh
```

## 📄 License

MIT
