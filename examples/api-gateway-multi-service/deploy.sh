#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

AWS_REGION=${AWS_REGION:-us-east-1}
IMAGE_TAG=${IMAGE_TAG:-latest}

echo "=== Multi-Service Deployment ==="
echo "Region: $AWS_REGION"
echo "Image Tag: $IMAGE_TAG"
echo ""

# Check prerequisites
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    exit 1
fi

# Step 1: Initialize Terraform
echo "Step 1: Initializing Terraform..."
terraform init

# Step 2: Create ECR repositories
echo ""
echo "Step 2: Creating ECR repositories..."
terraform apply -target=module.ecr_fastapi -target=module.ecr_mcp -auto-approve

# Get ECR URLs
FASTAPI_ECR_URL=$(terraform output -raw fastapi_ecr_url)
MCP_ECR_URL=$(terraform output -raw mcp_ecr_url)

echo "FastAPI ECR: $FASTAPI_ECR_URL"
echo "MCP ECR: $MCP_ECR_URL"

# Step 3: Login to ECR
echo ""
echo "Step 3: Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $FASTAPI_ECR_URL

# Step 4: Build and push FastAPI
echo ""
echo "Step 4: Building and pushing FastAPI service..."
cd fastapi-service
docker build --platform linux/amd64 -t $FASTAPI_ECR_URL:$IMAGE_TAG -t $FASTAPI_ECR_URL:latest .
docker push $FASTAPI_ECR_URL:$IMAGE_TAG
docker push $FASTAPI_ECR_URL:latest
cd ..

# Step 5: Build and push MCP
echo ""
echo "Step 5: Building and pushing MCP service..."
cd mcp-service
docker build --platform linux/amd64 -t $MCP_ECR_URL:$IMAGE_TAG -t $MCP_ECR_URL:latest .
docker push $MCP_ECR_URL:$IMAGE_TAG
docker push $MCP_ECR_URL:latest
cd ..

# Step 6: Deploy infrastructure
echo ""
echo "Step 6: Deploying infrastructure..."
terraform apply -auto-approve

echo ""
echo "=== Deployment Complete ==="
echo ""
terraform output test_commands
