# Terraform AWS Serverless Modules - Examples

Repository: [terraform-aws-serverless-modules](https://github.com/jonmatum/terraform-aws-serverless-modules)

This directory contains practical examples demonstrating how to use the Terraform modules for building serverless applications on AWS. Examples are organized from simple to complex.

## Learning Path

### 1. Foundation: Basic Deployments

Start here to understand core deployment patterns.

#### [lambda-function](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/lambda-function)
Containerized Lambda function with Function URL. Learn the basics of:
- Lambda container image deployment
- Function URL with CORS
- CloudWatch monitoring and alarms
- Dead Letter Queue (DLQ) for failed invocations
- Production reliability features (optional)

#### [ecs-app](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/ecs-app)
Simple FastAPI application on ECS with ALB. Learn the basics of:
- ECS Fargate deployment
- Application Load Balancer setup
- Docker image building and ECR
- Basic infrastructure patterns

### 2. API Gateway Integration

Learn how to expose services through API Gateway.

#### [rest-api-service](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/rest-api-service)
FastAPI behind API Gateway REST API (v1) with VPC Link. Introduces:
- API Gateway REST API (v1)
- VPC Link with Network Load Balancer
- Private service exposure
- Path-based routing (`/api/*`)

### 3. OpenAPI/Swagger Integration

Automate API Gateway configuration from OpenAPI specifications.

#### [openapi-rest-api](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/openapi-rest-api)
FastAPI with automatic OpenAPI schema import to REST API. Learn:
- OpenAPI 3.0 to Swagger 2.0 conversion
- Automatic API Gateway configuration from schema
- CRUD endpoint patterns
- Schema-driven development

#### [openapi-http-api](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/openapi-http-api)
FastAPI with OpenAPI schema import to HTTP API (v2). Demonstrates:
- HTTP API (v2) with OpenAPI
- Direct ALB integration (no NLB needed)
- Cost optimization vs REST API
- Modern API Gateway patterns

### 4. Full-Stack CRUD Applications

Complete applications with frontend, backend, and database.

#### [crud-api-rest](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/crud-api-rest)
Full CRUD app with REST API, React frontend, and DynamoDB. Features:
- React frontend on CloudFront + S3
- FastAPI backend with DynamoDB
- API Gateway REST API with Swagger
- WAF integration (optional)
- Complete CRUD operations

**Architecture**: `CloudFront → API Gateway REST → NLB → ALB → ECS → DynamoDB`

#### [crud-api-http](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/crud-api-http)
**Optimized** CRUD app using HTTP API (v2). Same features as above but:
- 71% cheaper than REST API
- Direct ALB integration (no NLB)
- Lower latency
- Simpler architecture

**Architecture**: `CloudFront → API Gateway HTTP → ALB → ECS → DynamoDB`

### 5. Advanced Patterns

#### [agentcore-full](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/agentcore-full)
Comprehensive AWS Bedrock AgentCore example with all capabilities. Features:
- Multiple MCP servers (ECS + Lambda)
- Knowledge Base with OpenSearch Serverless
- Bedrock Agent with action groups
- Guardrails (content filtering, PII redaction)
- AWS Well-Architected Framework compliant
- All features optional via feature flags

**Requires**: AWS Provider >= 6.18.0

#### [api-gateway-multi-service](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/api-gateway-multi-service)
Multiple services behind a single API Gateway. Learn:
- Multi-service architecture
- Path-based routing to different services
- FastAPI + Node.js MCP services
- Service isolation and scaling

**Routes**:
- `/api/fastapi/*` → FastAPI service
- `/api/mcp/*` → Node MCP service

#### [mcp-agent-runtime](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/mcp-agent-runtime)
Model Context Protocol (MCP) server with Bedrock AgentCore Gateway. Advanced topics:
- Amazon Bedrock AgentCore Gateway integration
- MCP protocol implementation
- Internal ALB with private ECS
- Auto-scaling and Spot instances

**Requires**: AWS Provider >= 6.18.0

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
| **Cost** |  $1.00/million |  $3.50/million |
| **VPC Integration** |  Direct to ALB |  Requires NLB |
| **Latency** |  Lower |  Higher (extra hop) |
| **OpenAPI** |  Yes |  Yes |
| **CORS** |  Built-in |  Manual config |
| **API Keys** |  No |  Yes |
| **Usage Plans** |  No |  Yes |
| **Request Validation** |  Limited |  Full |

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

### Serverless Function
```
Internet → Lambda Function URL
```
Example: [lambda-function](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/lambda-function)

### Simple Service
```
Internet → ALB → ECS (Fargate)
```
Example: [ecs-app](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/ecs-app)

### API Gateway + Private Service
```
Internet → API Gateway → VPC Link → NLB/ALB → ECS
```
Examples: [rest-api-service](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/rest-api-service), [openapi-http-api](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/openapi-http-api)

### Full-Stack Application
```
Internet → CloudFront → S3 (Frontend)
              ↓
         API Gateway → VPC Link → ECS (Backend) → DynamoDB
```
Examples: [crud-api-rest](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/crud-api-rest), [crud-api-http](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/crud-api-http)

### Multi-Service Gateway
```
Internet → API Gateway → VPC Link → ALB → Multiple ECS Services
```
Example: [api-gateway-multi-service](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/api-gateway-multi-service)

### AgentCore with MCP Servers
```
AgentCore Gateway → ECS MCP Server (Fargate)
                 → Lambda MCP Server (Function URL)

Knowledge Base → S3 + OpenSearch Serverless
Bedrock Agent → Lambda Actions
```
Example: [agentcore-full](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/agentcore-full)

## Cost Optimization Tips

1. **Use HTTP API (v2)** instead of REST API when possible (71% cheaper)
2. **Enable Spot instances** for non-critical workloads (50% cost reduction)
3. **Right-size ECS tasks** - start small and scale up as needed
4. **Use CloudFront caching** to reduce backend requests
5. **Enable DynamoDB on-demand** for unpredictable workloads

## Support

For issues or questions, please open an issue in the [GitHub repository](https://github.com/jonmatum/terraform-aws-serverless-modules/issues).
