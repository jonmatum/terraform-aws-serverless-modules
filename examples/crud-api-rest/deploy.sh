#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"
APP_DIR="$SCRIPT_DIR/fastapi-app"

IMAGE_TAG=${1:-latest}
AWS_REGION=${AWS_REGION:-us-east-1}

echo "=== CRUD API (REST) Deployment ==="
echo "Region: $AWS_REGION"
echo "Image Tag: $IMAGE_TAG"
echo ""

# Change to Terraform directory
cd "$TERRAFORM_DIR"

# Step 1: Initialize Terraform
echo "Step 1: Initializing Terraform..."
terraform init

# Step 2: Apply infrastructure
echo ""
echo "Step 2: Applying infrastructure (initial resources)..."
terraform apply -target=module.vpc -target=module.dynamodb -target=module.ecr -target=module.alb -target=module.ecs -auto-approve

echo ""
echo "Step 2b: Applying remaining infrastructure..."
terraform apply -auto-approve

# Get ECR URL
ECR_URL=$(terraform output -raw ecr_repository_url)

# Step 3: Build and push Docker image
echo ""
echo "Step 3: Building and pushing Docker image..."
docker build --platform linux/amd64 -t crud-api:${IMAGE_TAG} "$APP_DIR"
docker tag crud-api:${IMAGE_TAG} ${ECR_URL}:${IMAGE_TAG}
docker tag crud-api:${IMAGE_TAG} ${ECR_URL}:latest

aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}
docker push ${ECR_URL}:${IMAGE_TAG}
docker push ${ECR_URL}:latest

# Step 4: Force ECS service update
echo ""
echo "Step 4: Updating ECS service..."

# Refresh outputs
terraform refresh > /dev/null

CLUSTER_NAME=$(terraform output -raw cluster_name)
SERVICE_NAME=$(terraform output -raw service_name)

aws ecs update-service --region ${AWS_REGION} --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --force-new-deployment --no-cli-pager > /dev/null

echo ""
echo "=== Deployment Complete ==="
API_ENDPOINT=$(terraform output -raw api_endpoint)
echo "API Endpoint: ${API_ENDPOINT}"
echo ""
echo "Test commands:"
echo "  # Create item"
echo "  curl -X POST ${API_ENDPOINT}/items -H 'Content-Type: application/json' -d '{\"name\":\"Laptop\",\"description\":\"MacBook Pro\",\"price\":2499.99,\"quantity\":10}'"
echo ""
echo "  # List items"
echo "  curl ${API_ENDPOINT}/items"
