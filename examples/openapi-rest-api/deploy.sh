#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

AWS_REGION=${AWS_REGION:-us-east-1}
IMAGE_TAG=${IMAGE_TAG:-latest}

echo "=== OpenAPI REST API Deployment ==="
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

# Step 2: Create ECR repository
echo ""
echo "Step 2: Creating ECR repository..."
terraform apply -target=module.ecr -auto-approve

# Get ECR URL
ECR_URL=$(terraform output -raw ecr_repository_url)
echo "ECR URL: $ECR_URL"

# Step 3: Login to ECR
echo ""
echo "Step 3: Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL

# Step 4: Build and push Docker image
echo ""
echo "Step 4: Building and pushing Docker image..."
docker build --platform linux/amd64 -t $ECR_URL:$IMAGE_TAG .
docker push $ECR_URL:$IMAGE_TAG

# Step 5: Deploy infrastructure
echo ""
echo "Step 5: Deploying infrastructure..."
terraform apply -auto-approve

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "OpenAPI spec generated at: openapi.json"
echo ""
terraform output test_commands
