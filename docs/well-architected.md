# AWS Well-Architected Framework Implementation

This document outlines how our Terraform modules implement AWS Well-Architected Framework best practices.

## Security Pillar ✅

### Encryption
- **ECR**: Encryption at rest enabled by default (AES256, optional KMS)
- **S3**: ALB access logs bucket with encryption and public access blocked

### IAM Least Privilege
- ECR permissions scoped to specific repository ARNs
- Separate execution and task roles
- Support for Secrets Manager/SSM Parameter Store integration

### Network Security
- Security groups with specific port rules and descriptions
- Private subnets for ECS tasks
- VPC endpoints to avoid internet traffic for AWS services

### Secrets Management
- Native support for AWS Secrets Manager
- SSM Parameter Store integration
- No hardcoded credentials in container definitions

## Reliability Pillar ✅

### High Availability
- Multi-AZ NAT gateways by default (configurable for dev)
- ALBs span multiple availability zones
- ECS services with health checks

### Auto-Scaling
- ECS Service Auto Scaling with target tracking
- CPU and memory-based scaling policies
- Configurable min/max capacity

### Fault Tolerance
- Health check grace periods
- Connection draining (deregistration delay)
- Unhealthy target detection and replacement

### Monitoring & Alarms
- CloudWatch alarms for CPU, memory, response time
- ALB 5XX error monitoring
- Unhealthy host count tracking

## Operational Excellence Pillar ✅

### Observability
- Container Insights enabled by default
- ALB access logs to S3
- 30-day log retention (configurable)
- Structured logging with CloudWatch

### Infrastructure as Code
- Modular Terraform design
- Reusable components
- Version-controlled configurations

### Monitoring
- CloudWatch metrics and alarms
- Optional SNS notifications
- ALB and ECS service metrics

## Performance Efficiency Pillar ✅

### Compute Optimization
- Fargate serverless compute
- Optional Fargate Spot for cost savings
- Configurable CPU/memory allocation

### Network Optimization
- VPC endpoints reduce NAT Gateway traffic
- Connection draining for graceful shutdowns
- Target-based health checks

### Caching & CDN
- Ready for CloudFront integration
- API Gateway caching support

## Cost Optimization Pillar ✅

### Resource Optimization
- VPC endpoints reduce data transfer costs
- Fargate Spot support (up to 70% savings)
- ECR lifecycle policies (keep last 10 images)

### Right-Sizing
- Auto-scaling prevents over-provisioning
- Configurable task sizes
- Single NAT option for dev/test

### Cost Allocation
- Standard tagging strategy (Environment, Project, ManagedBy)
- Resource-level cost tracking
- S3 lifecycle policies for log retention

## Sustainability Pillar ✅

### Resource Efficiency
- Auto-scaling reduces idle resources
- Fargate eliminates EC2 over-provisioning
- VPC endpoints reduce network hops

### Optimization
- Right-sized task definitions
- Efficient container images
- Log retention policies

---

## Module Configuration Examples

### High Availability Production Setup

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name               = "prod-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["us-east-1a", "us-east-1b", "us-east-1c"]
  enable_nat_gateway = true
  single_nat_gateway = false  # Multi-AZ for HA
  enable_vpc_endpoints = true

  tags = {
    Environment = "production"
    Project     = "my-app"
    ManagedBy   = "terraform"
  }
}

module "ecs" {
  source = "../../modules/ecs"

  # ... other config ...

  enable_autoscaling        = true
  autoscaling_min_capacity  = 2
  autoscaling_max_capacity  = 10
  autoscaling_cpu_target    = 70
  autoscaling_memory_target = 80
  enable_container_insights = true

  tags = var.tags
}

module "alb" {
  source = "../../modules/alb"

  # ... other config ...

  enable_access_logs       = true
  deregistration_delay     = 30
  enable_https             = true
  certificate_arn          = "arn:aws:acm:..."
  redirect_http_to_https   = true

  tags = var.tags
}

module "ecr" {
  source = "../../modules/ecr"

  repository_name         = "my-app"
  encryption_type         = "KMS"
  kms_key_arn            = "arn:aws:kms:..."
  enable_lifecycle_policy = true
  scan_on_push           = true

  tags = var.tags
}
```

### Cost-Optimized Dev Setup

```hcl
module "vpc" {
  source = "../../modules/vpc"

  name               = "dev-vpc"
  single_nat_gateway = true  # Single NAT for cost savings
  enable_vpc_endpoints = true  # Still use VPC endpoints

  tags = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

module "ecs" {
  source = "../../modules/ecs"

  # ... other config ...

  enable_fargate_spot    = true
  fargate_spot_weight    = 70  # 70% Spot, 30% On-Demand
  autoscaling_min_capacity = 1
  autoscaling_max_capacity = 4

  tags = var.tags
}
```

### Secrets Management

```hcl
module "ecs" {
  source = "../../modules/ecs"

  # ... other config ...

  environment_variables = [
    {
      name  = "APP_ENV"
      value = "production"
    }
  ]

  secrets = [
    {
      name      = "DATABASE_PASSWORD"
      valueFrom = "arn:aws:secretsmanager:us-east-1:123456789:secret:db-password"
    },
    {
      name      = "API_KEY"
      valueFrom = "arn:aws:ssm:us-east-1:123456789:parameter/api-key"
    }
  ]
}
```

---

## Default Behaviors

### Security Defaults
- ✅ ECR encryption enabled (AES256)
- ✅ ECR image scanning on push
- ✅ ALB access logs enabled
- ✅ VPC endpoints enabled
- ✅ Security groups with specific ports

### Reliability Defaults
- ✅ Container Insights enabled
- ✅ Auto-scaling enabled (1-4 tasks)
- ✅ Multi-AZ NAT gateways
- ✅ Health check grace period: 60s
- ✅ Connection draining: 30s

### Cost Optimization Defaults
- ✅ ECR lifecycle policy (keep 10 images)
- ✅ S3 log retention: 90 days
- ✅ CloudWatch log retention: 30 days
- ⚠️ Fargate Spot: disabled (opt-in)
- ⚠️ Single NAT: disabled (opt-in for dev)

---

## Compliance & Best Practices

### ✅ Implemented
- Encryption at rest and in transit
- Least privilege IAM policies
- Network segmentation
- Automated scaling
- Comprehensive monitoring
- Cost allocation tagging
- Lifecycle management
- High availability

### 🔄 Optional Enhancements
- WAF integration (add WAF module)
- CloudFront CDN (add CloudFront module)
- X-Ray tracing (add X-Ray sidecar)
- Custom KMS keys (specify kms_key_arn)
- HTTPS/TLS (provide certificate_arn)

---

## Migration Guide

### From Basic Setup to Well-Architected

1. **Enable VPC Endpoints** (reduces NAT costs)
   ```hcl
   enable_vpc_endpoints = true
   ```

2. **Add Multi-AZ NAT** (production only)
   ```hcl
   single_nat_gateway = false
   ```

3. **Enable Auto-Scaling** (already default)
   ```hcl
   enable_autoscaling = true
   ```

4. **Add Cost Tags**
   ```hcl
   tags = {
     Environment = "production"
     Project     = "my-app"
     CostCenter  = "engineering"
     ManagedBy   = "terraform"
   }
   ```

5. **Enable Fargate Spot** (non-critical workloads)
   ```hcl
   enable_fargate_spot = true
   fargate_spot_weight = 50
   ```

6. **Add HTTPS** (when you have a certificate)
   ```hcl
   enable_https           = true
   certificate_arn        = "arn:aws:acm:..."
   redirect_http_to_https = true
   ```
