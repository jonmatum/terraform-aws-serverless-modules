# REST API Service Example

FastAPI service behind API Gateway v1 (REST API) with VPC Link and NLB.

## Architecture

- FastAPI service on ECS (port 8000)
- Network Load Balancer (NLB) in private subnets
- API Gateway REST API with VPC Link to NLB
- All traffic routed through `/api/*` path

## Deployment

### Initial Deployment

```bash
./deploy.sh
```

### Redeploy After Code Changes

```bash
# Redeploy with auto-generated tag
./redeploy.sh

# Redeploy with specific tag
IMAGE_TAG=v1.2.3 ./redeploy.sh

# CI/CD usage
export AWS_REGION=us-east-1
export IMAGE_TAG=$GITHUB_SHA
./redeploy.sh
```

## Testing

```bash
# Get API endpoint
API_ENDPOINT=$(terraform output -raw api_endpoint)

# Test the service
curl $API_ENDPOINT/api/hello

# Test health check
curl $API_ENDPOINT/api/health
```

## Differences from HTTP API (v2)

- Uses REST API (v1) instead of HTTP API (v2)
- Requires Network Load Balancer for VPC Link
- More configuration options and features
- Supports API keys, usage plans, and request validation
- Higher latency compared to HTTP API
