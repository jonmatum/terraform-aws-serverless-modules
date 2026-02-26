# Terraform AWS Serverless Modules - Examples

Repository: [terraform-aws-serverless-modules](https://github.com/jonmatum/terraform-aws-serverless-modules)

This directory contains practical examples demonstrating how to use the Terraform modules for building serverless applications on AWS. Examples are organized from simple to complex.

## Learning Path

### 1. Foundation: Basic ECS Deployment

Start here to understand the core ECS deployment pattern.

#### [ecs-app](./ecs-app/)
Simple FastAPI application on ECS with ALB. Learn the basics of:
- ECS Fargate deployment
- Application Load Balancer setup
- Docker image building and ECR
- Basic infrastructure patterns

### 2. API Gateway Integration

Learn how to expose services through API Gateway.

#### [rest-api-service](./rest-api-service/)
FastAPI behind API Gateway REST API (v1) with VPC Link. Introduces:
- API Gateway REST API (v1)
- VPC Link with Network Load Balancer
- Private service exposure
- Path-based routing (`/api/*`)

### 3. OpenAPI/Swagger Integration

Automate API Gateway configuration from OpenAPI specifications.

#### [openapi-rest-api](./openapi-rest-api/)
FastAPI with automatic OpenAPI schema import to REST API. Learn:
- OpenAPI 3.0 to Swagger 2.0 conversion
- Automatic API Gateway configuration from schema
- CRUD endpoint patterns
- Schema-driven development

#### [openapi-http-api](./openapi-http-api/)
FastAPI with OpenAPI schema import to HTTP API (v2). Demonstrates:
- HTTP API (v2) with OpenAPI
- Direct ALB integration (no NLB needed)
- Cost optimization vs REST API
- Modern API Gateway patterns

### 4. Full-Stack CRUD Applications

Complete applications with frontend, backend, and database.

#### [crud-api-rest](./crud-api-rest/)
Full CRUD app with REST API, React frontend, and DynamoDB. Features:
- React frontend on CloudFront + S3
- FastAPI backend with DynamoDB
- API Gateway REST API with Swagger
- WAF integration (optional)
- Complete CRUD operations

**Architecture**: `CloudFront → API Gateway REST → NLB → ALB → ECS → DynamoDB`

#### [crud-api-http](./crud-api-http/)
**Optimized** CRUD app using HTTP API (v2). Same features as above but:
- 71% cheaper than REST API
- Direct ALB integration (no NLB)
- Lower latency
- Simpler architecture

**Architecture**: `CloudFront → API Gateway HTTP → ALB → ECS → DynamoDB`

📖 See [CRUD_API_COMPARISON.md](./CRUD_API_COMPARISON.md) for detailed comparison.

### 5. Advanced Patterns

#### [api-gateway-multi-service](./api-gateway-multi-service/)
Multiple services behind a single API Gateway. Learn:
- Multi-service architecture
- Path-based routing to different services
- FastAPI + Node.js MCP services
- Service isolation and scaling

**Routes**:
- `/api/fastapi/*` → FastAPI service
- `/api/mcp/*` → Node MCP service

#### [mcp-agent-runtime](./mcp-agent-runtime/)
Model Context Protocol (MCP) server with Bedrock AgentCore Gateway. Advanced topics:
- Amazon Bedrock AgentCore Gateway integration
- MCP protocol implementation
- Internal ALB with private ECS
- Auto-scaling and Spot instances

**⚠️ Requires**: AWS Provider >= 6.18.0

## Quick Start

Each example includes deployment scripts:

```bash
cd <example-directory>
./deploy.sh        # Initial deployment
./redeploy.sh      # Redeploy after code changes
```

## API Gateway: REST vs HTTP

| Feature | HTTP API (v2) | REST API (v1) |
|---------|---------------|---------------|
| **Cost** | ✅ $1.00/million | ❌ $3.50/million |
| **VPC Integration** | ✅ Direct to ALB | ❌ Requires NLB |
| **Latency** | ✅ Lower | ⚠️ Higher (extra hop) |
| **OpenAPI** | ✅ Yes | ✅ Yes |
| **CORS** | ✅ Built-in | ✅ Manual config |
| **API Keys** | ❌ No | ✅ Yes |
| **Usage Plans** | ❌ No | ✅ Yes |
| **Request Validation** | ❌ Limited | ✅ Full |

**Recommendation**: Use HTTP API (v2) unless you need API keys or usage plans.

## Prerequisites

- AWS CLI configured
- Terraform >= 1.0
- Docker
- jq (for deployment scripts)

## Common Commands

```bash
# Deploy infrastructure and application
./deploy.sh

# Redeploy after code changes
./redeploy.sh

# Redeploy with specific tag
IMAGE_TAG=v1.2.3 ./redeploy.sh

# Destroy infrastructure
terraform destroy
```

## Architecture Patterns

### Simple Service
```
Internet → ALB → ECS (Fargate)
```
Example: [ecs-app](./ecs-app/)

### API Gateway + Private Service
```
Internet → API Gateway → VPC Link → NLB/ALB → ECS
```
Examples: [rest-api-service](./rest-api-service/), [openapi-http-api](./openapi-http-api/)

### Full-Stack Application
```
Internet → CloudFront → S3 (Frontend)
              ↓
         API Gateway → VPC Link → ECS (Backend) → DynamoDB
```
Examples: [crud-api-rest](./crud-api-rest/), [crud-api-http](./crud-api-http/)

### Multi-Service Gateway
```
Internet → API Gateway → VPC Link → ALB → Multiple ECS Services
```
Example: [api-gateway-multi-service](./api-gateway-multi-service/)

## Cost Optimization Tips

1. **Use HTTP API (v2)** instead of REST API when possible (71% cheaper)
2. **Enable Spot instances** for non-critical workloads (50% cost reduction)
3. **Right-size ECS tasks** - start small and scale up as needed
4. **Use CloudFront caching** to reduce backend requests
5. **Enable DynamoDB on-demand** for unpredictable workloads

## Support

For issues or questions, please open an issue in the [GitHub repository](https://github.com/jonmatum/terraform-aws-serverless-modules/issues).
