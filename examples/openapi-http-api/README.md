# OpenAPI HTTP API Example

FastAPI application with automatic OpenAPI schema import to API Gateway HTTP API (v2).

## Features

- FastAPI app with multiple CRUD endpoints
- Automatic OpenAPI/Swagger schema generation
- API Gateway HTTP API configured from OpenAPI spec
- Full REST API for user management (GET, POST, PUT, DELETE)
- VPC Link integration with NLB

## Architecture

1. FastAPI generates OpenAPI 3.0 schema
2. Terraform extracts schema and configures API Gateway
3. API Gateway routes defined by OpenAPI spec
4. VPC Link connects to ECS service via NLB

## Deployment

### Initial Deployment

```bash
./deploy.sh
```

This will:
1. Generate OpenAPI spec from FastAPI app
2. Create infrastructure with API Gateway configured from spec
3. Deploy ECS service

### Redeploy After Code Changes

```bash
./redeploy.sh
```

## Testing

```bash
API_ENDPOINT=$(terraform output -raw api_endpoint)

# List users
curl $API_ENDPOINT/users

# Get user
curl $API_ENDPOINT/users/1

# Create user
curl -X POST $API_ENDPOINT/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Alice","email":"alice@example.com"}'

# Update user
curl -X PUT $API_ENDPOINT/users/1 \
  -H "Content-Type: application/json" \
  -d '{"name":"John Updated"}'

# Delete user
curl -X DELETE $API_ENDPOINT/users/2
```

## OpenAPI Spec

The OpenAPI specification is automatically generated at `openapi.json` during deployment. View it to see all available endpoints and schemas.

## Local Development

```bash
pip install -r requirements.txt
uvicorn app:app --reload

# View docs at http://localhost:8000/docs
```
