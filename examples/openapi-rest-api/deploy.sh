#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

AWS_REGION=${AWS_REGION:-us-east-1}

echo "=== OpenAPI REST API Deployment ==="
echo "Region: $AWS_REGION"

# Step 1: Install Python dependencies
echo ""
echo "Step 1: Installing Python dependencies..."
pip3 install -q -r requirements.txt

# Step 2: Create ECR repository
echo ""
echo "Step 2: Creating ECR repository..."
terraform init
terraform apply -target=module.ecr -auto-approve

# Get ECR URL
ECR_URL=$(terraform output -raw ecr_repository_url)
echo "ECR URL: $ECR_URL"

# Step 3: Login to ECR
echo ""
echo "Step 3: Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL

# Step 4: Build and push image
echo ""
echo "Step 4: Building and pushing Docker image..."
docker build --platform linux/amd64 -t $ECR_URL:latest .
docker push $ECR_URL:latest

# Step 5: Deploy infrastructure
echo ""
echo "Step 5: Deploying infrastructure with OpenAPI spec..."
terraform apply -auto-approve

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "OpenAPI spec generated at: openapi.json"
echo ""
terraform output test_commands
