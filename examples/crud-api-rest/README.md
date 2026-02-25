# CRUD API with REST API (API Gateway v1) + React Frontend

Complete CRUD application with FastAPI backend, DynamoDB, API Gateway REST API with Swagger/OpenAPI, and React frontend on CloudFront.

## Architecture

```
Internet → CloudFront → S3 (React App)
              ↓
         API Gateway REST API (v1) → VPC Link → ALB → ECS (FastAPI) → DynamoDB
              ↓
         WAF (optional)
```

## Features

### Backend (FastAPI)
- ✅ Full CRUD operations (Create, Read, Update, Delete)
- ✅ DynamoDB integration
- ✅ Pydantic validation
- ✅ OpenAPI/Swagger documentation
- ✅ Health check endpoint
- ✅ CORS support

### Infrastructure
- ✅ API Gateway REST API with Swagger/OpenAPI spec
- ✅ VPC Link for private integration
- ✅ DynamoDB with encryption & PITR
- ✅ ECS Fargate with auto-scaling
- ✅ CloudFront + S3 for React app
- ✅ WAF protection (optional)
- ✅ CloudWatch Logs & monitoring
- ✅ X-Ray tracing support

### Frontend (React)
- ✅ Item list view
- ✅ Create/Edit forms
- ✅ Delete confirmation
- ✅ API integration
- ✅ Responsive design

## Quick Start

### 1. Deploy Infrastructure & Backend

```bash
./deploy.sh
```

This will:
1. Create all AWS infrastructure
2. Build and push FastAPI Docker image
3. Deploy ECS service
4. Output API endpoint and test commands

### 2. Test API

```bash
# Get API endpoint
export API_URL=$(terraform output -raw api_endpoint)

# Create an item
curl -X POST $API_URL/items \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop",
    "description": "MacBook Pro 16-inch",
    "price": 2499.99,
    "quantity": 10
  }'

# List all items
curl $API_URL/items

# Get specific item
curl $API_URL/items/{item-id}

# Update item
curl -X PUT $API_URL/items/{item-id} \
  -H "Content-Type: application/json" \
  -d '{"price": 2299.99}'

# Delete item
curl -X DELETE $API_URL/items/{item-id}

# Health check
curl $API_URL/health

# Open API documentation
open $API_URL/docs
```

### 3. Deploy React Frontend (Optional)

```bash
cd react-app
npm install
npm run build

# Deploy to S3/CloudFront
aws s3 sync build/ s3://$(terraform output -raw s3_bucket_name)/ --delete

# Invalidate CloudFront cache
aws cloudfront create-invalidation \
  --distribution-id $(terraform output -raw cloudfront_distribution_id) \
  --paths "/*"

# Open frontend
open $(terraform output -raw cloudfront_url)
```

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | API root |
| GET | `/health` | Health check |
| GET | `/docs` | Swagger UI |
| GET | `/redoc` | ReDoc UI |
| POST | `/items` | Create item |
| GET | `/items` | List all items |
| GET | `/items/{id}` | Get item by ID |
| PUT | `/items/{id}` | Update item |
| DELETE | `/items/{id}` | Delete item |

## Configuration

### Enable WAF

```hcl
# variables.tf or terraform.tfvars
enable_waf = true
```

### Customize Settings

```hcl
# variables.tf
variable "project_name" {
  default = "my-crud-api"
}

variable "aws_region" {
  default = "us-west-2"
}
```

## Cost Estimate

**Development** (~$70-90/month):
- DynamoDB: $1-5 (PAY_PER_REQUEST)
- ECS Fargate: $15-30
- NAT Gateway: $32 (single)
- ALB: $16
- API Gateway: $3.50/million requests
- CloudFront: $0.085/GB
- S3: $0.023/GB

**Production** (~$200-400/month):
- DynamoDB: $10-50
- ECS Fargate: $60-120 (auto-scaling)
- NAT Gateway: $64 (multi-AZ)
- ALB: $16
- API Gateway: Higher with traffic
- WAF: $5 + $1/million requests

## Cleanup

```bash
terraform destroy -auto-approve
```

## Well-Architected Compliance

- ✅ **Security**: Encryption, IAM least privilege, VPC endpoints, WAF
- ✅ **Reliability**: Multi-AZ, auto-scaling, health checks, PITR
- ✅ **Performance**: Fargate, DynamoDB PAY_PER_REQUEST, CloudFront
- ✅ **Cost**: Auto-scaling, lifecycle policies, VPC endpoints
- ✅ **Operations**: IaC, logging, monitoring, X-Ray tracing

## Troubleshooting

### ECS Service Won't Start
```bash
# Check ECS service events
aws ecs describe-services \
  --cluster $(terraform output -raw cluster_name) \
  --services $(terraform output -raw service_name)

# Check CloudWatch logs
aws logs tail /ecs/crud-api-rest-api --follow
```

### API Gateway Returns 500
```bash
# Check ALB target health
aws elbv2 describe-target-health \
  --target-group-arn $(terraform output -raw target_group_arn)
```

### DynamoDB Access Denied
- Verify ECS task role has DynamoDB permissions
- Check table name environment variable

## Next Steps

1. Add authentication (Cognito)
2. Add CI/CD pipeline
3. Add integration tests
4. Add monitoring dashboards
5. Add custom domain
6. Add rate limiting per user
