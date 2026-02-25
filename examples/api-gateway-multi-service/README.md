# Multi-Service API Gateway Example

FastAPI and Node MCP services behind API Gateway with VPC Link.

## Architecture

- FastAPI service on ECS (port 8000) → `/api/fastapi/*`
- Node MCP service on ECS (port 3000) → `/api/mcp/*`
- API Gateway HTTP API with VPC Link to private ECS services
- Services in private subnets, exposed via API Gateway

## Deployment

### Initial Deployment

```bash
./deploy.sh
```

### Redeploy All Services

```bash
# Redeploy both services with auto-generated tag
./redeploy.sh

# Redeploy with specific tag
IMAGE_TAG=v1.2.3 ./redeploy.sh

# Redeploy only FastAPI
./redeploy.sh fastapi

# Redeploy only MCP
./redeploy.sh mcp
```

### CI/CD Usage

```bash
# In GitHub Actions or other CI/CD
export AWS_REGION=us-east-1
export IMAGE_TAG=$GITHUB_SHA
./redeploy.sh
```

## Testing

```bash
# Get API endpoint
API_ENDPOINT=$(terraform output -raw api_endpoint)

# Test FastAPI
curl $API_ENDPOINT/api/fastapi

# Test MCP
curl $API_ENDPOINT/api/mcp
```
