#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"
FASTAPI_DIR="$SCRIPT_DIR/fastapi-service"
MCP_DIR="$SCRIPT_DIR/mcp-service"

IMAGE_TAG=${1:-latest}
AWS_REGION=${AWS_REGION:-us-east-1}

echo "=== Multi-Service Deployment ==="
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
echo "Step 2: Applying infrastructure..."
terraform apply -auto-approve

# Get ECR URLs
FASTAPI_ECR_URL=$(terraform output -raw fastapi_ecr_url)
MCP_ECR_URL=$(terraform output -raw mcp_ecr_url)

# Step 3: Build and push FastAPI
echo ""
echo "Step 3: Building and pushing FastAPI service..."
docker build --platform linux/amd64 -t fastapi:${IMAGE_TAG} "$FASTAPI_DIR"
docker tag fastapi:${IMAGE_TAG} ${FASTAPI_ECR_URL}:${IMAGE_TAG}

aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${FASTAPI_ECR_URL}
docker push ${FASTAPI_ECR_URL}:${IMAGE_TAG}

# Step 4: Build and push MCP
echo ""
echo "Step 4: Building and pushing MCP service..."
docker build --platform linux/amd64 -t mcp:${IMAGE_TAG} "$MCP_DIR"
docker tag mcp:${IMAGE_TAG} ${MCP_ECR_URL}:${IMAGE_TAG}

aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${MCP_ECR_URL}
docker push ${MCP_ECR_URL}:${IMAGE_TAG}

# Step 5: Force ECS service update
echo ""
echo "Step 5: Updating ECS services..."

# Refresh outputs to get service names
terraform refresh > /dev/null

FASTAPI_CLUSTER=$(terraform output -raw ecs_fastapi_cluster_name)
FASTAPI_SERVICE=$(terraform output -raw ecs_fastapi_service_name)
MCP_CLUSTER=$(terraform output -raw ecs_mcp_cluster_name)
MCP_SERVICE=$(terraform output -raw ecs_mcp_service_name)

aws ecs update-service --region ${AWS_REGION} --cluster ${FASTAPI_CLUSTER} --service ${FASTAPI_SERVICE} --force-new-deployment --no-cli-pager > /dev/null
aws ecs update-service --region ${AWS_REGION} --cluster ${MCP_CLUSTER} --service ${MCP_SERVICE} --force-new-deployment --no-cli-pager > /dev/null

echo ""
echo "=== Deployment Complete ==="
API_ENDPOINT=$(terraform output -raw api_endpoint)
echo "API Endpoint: ${API_ENDPOINT}"
echo ""
echo "Test commands:"
echo "  curl ${API_ENDPOINT}/api/fastapi"
echo "  curl ${API_ENDPOINT}/api/mcp"
