# OpenAPI REST API Example

FastAPI application with automatic OpenAPI schema import to API Gateway REST API (v1).

## Features

- FastAPI app with multiple CRUD endpoints
- Automatic OpenAPI/Swagger 2.0 schema generation
- API Gateway REST API configured from OpenAPI spec
- Full REST API for product management (GET, POST, PUT, DELETE)
- VPC Link integration with NLB

## Architecture

1. FastAPI generates OpenAPI 3.0 schema
2. Schema converted to Swagger 2.0 for REST API compatibility
3. Terraform imports schema and configures API Gateway
4. VPC Link connects to ECS service via NLB

## Deployment

### Initial Deployment

```bash
./deploy.sh
```

### Redeploy After Code Changes

```bash
./redeploy.sh
```

## Testing

```bash
API_ENDPOINT=$(terraform output -raw api_endpoint)

# List products
curl $API_ENDPOINT/products

# Get product
curl $API_ENDPOINT/products/1

# Create product
curl -X POST $API_ENDPOINT/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Laptop","price":999.99,"stock":10}'

# Update product
curl -X PUT $API_ENDPOINT/products/1 \
  -H "Content-Type: application/json" \
  -d '{"price":899.99}'

# Delete product
curl -X DELETE $API_ENDPOINT/products/2
```

## OpenAPI Spec

The OpenAPI specification is automatically generated at `openapi.json` during deployment.

## Local Development

```bash
pip install -r requirements.txt
uvicorn app:app --reload

# View docs at http://localhost:8000/docs
```
