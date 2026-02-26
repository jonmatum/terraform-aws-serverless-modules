# AWS Well-Architected Framework Compliance

## Overview

This module implements API Gateway REST API (v1) with VPC Link integration following AWS Well-Architected Framework principles.

## Architecture Decision

API Gateway REST API v1 VPC Links **require** Network Load Balancer (NLB). This is an AWS platform limitation, not a design choice.

### Supported Patterns

1. **NLB → ALB → Backend** (OpenAPI mode)
   - Use when you need ALB features (path routing, host-based routing, WAF)
   - Cost: ~$32/month (NLB + ALB)
   - Latency: +1-3ms

2. **NLB → Backend** (Legacy mode)
   - Use for simple proxy scenarios
   - Cost: ~$16/month (NLB only)
   - Latency: Minimal

## Well-Architected Pillars

### 1. Operational Excellence 
- Infrastructure as Code (Terraform)
- Automated deployments
- CloudWatch logging enabled by default
- X-Ray tracing support
- Proper tagging strategy

### 2. Security 
- Private integration via VPC Link
- No public endpoints to backend
- Encryption in transit (TLS)
- IAM-based access control
- Optional WAF integration

### 3. Reliability 
- Multi-AZ deployment (NLB in multiple subnets)
- Cross-zone load balancing enabled
- Health checks configured
- Graceful connection draining (30s deregistration delay)
- Auto-scaling support

### 4. Performance Efficiency 
- **Trade-off**: NLB → ALB adds network hop
- **Mitigation**: Use HTTP API (v2) if REST API v1 features not needed
- **Benefit**: NLB provides high throughput and low latency

### 5. Cost Optimization 
- **Cost**: NLB adds ~$16/month
- **Alternative**: HTTP API (v2) supports ALB directly (no NLB needed)
- **When to use REST API v1**:
  - Need API keys and usage plans
  - Need request/response transformation
  - Need request validation
  - Need SDK generation
- **When to use HTTP API (v2)**:
  - Simple proxy use case
  - Cost-sensitive workloads
  - Lower latency requirements

### 6. Sustainability 
- **Impact**: Extra NLB increases resource usage
- **Mitigation**: Consider HTTP API (v2) for simpler workloads

## Recommendations

### Use REST API v1 (this module) when:
-  You need API keys and usage plans
-  You need request/response transformation
-  You need request validation
-  You need SDK generation
-  You need detailed CloudWatch metrics

### Use HTTP API v2 (api-gateway module) when:
-  Simple proxy to backend
-  Cost optimization is priority
-  Lower latency is priority
-  Don't need REST API v1 specific features

## Configuration Best Practices

```hcl
module "api_gateway_v1" {
  source = "../../modules/api-gateway-v1"

  # Required
  name                = "my-api"
  vpc_link_subnet_ids = ["subnet-1", "subnet-2"] # Multi-AZ

  # OpenAPI mode (with ALB)
  openapi_spec      = file("swagger.json")
  alb_arn           = module.alb.alb_arn
  vpc_id            = module.vpc.vpc_id
  health_check_path = "/health"

  # Well-Architected settings
  enable_deletion_protection = true  # Production
  enable_nlb_access_logs     = true  # Compliance
  nlb_access_logs_bucket     = "my-logs-bucket"
  enable_xray_tracing        = true  # Observability
  enable_access_logs         = true  # Audit

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

## Monitoring

### Key Metrics
- API Gateway: 4XXError, 5XXError, Latency, Count
- NLB: HealthyHostCount, UnHealthyHostCount, ProcessedBytes
- ALB: TargetResponseTime, HTTPCode_Target_4XX_Count

### Alarms (Recommended)
- API Gateway 5XX errors > threshold
- NLB unhealthy targets > 0
- API Gateway latency > p99 threshold

## Cost Analysis

| Component | Monthly Cost | Annual Cost |
|-----------|-------------|-------------|
| NLB | $16.20 | $194.40 |
| ALB | $16.20 | $194.40 |
| API Gateway | $3.50/million | Variable |
| Data Transfer | $0.09/GB | Variable |

**Total Fixed**: ~$32/month (~$389/year)

## Migration Path

If cost becomes a concern, migrate to HTTP API (v2):

1. Assess REST API v1 feature usage
2. Test with HTTP API (v2) in dev
3. Update integrations to use ALB directly
4. Remove NLB resources
5. Update DNS/endpoints

**Savings**: ~$16/month (~$194/year)
