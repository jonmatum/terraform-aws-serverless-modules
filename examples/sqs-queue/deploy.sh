#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"
PROCESSOR_DIR="$SCRIPT_DIR/processor"

IMAGE_TAG=${1:-latest}
AWS_REGION=${AWS_REGION:-us-east-1}

echo "=== SQS Queue Example Deployment ==="
echo "Region: $AWS_REGION"
echo "Image Tag: $IMAGE_TAG"
echo ""

# Change to Terraform directory
cd "$TERRAFORM_DIR"

# Step 1: Initialize Terraform
echo "Step 1: Initializing Terraform..."
terraform init

# Step 2: Create ECR repository
echo ""
echo "Step 2: Creating ECR repository..."
terraform apply -target=module.ecr -auto-approve
terraform refresh -target=module.ecr > /dev/null

# Get ECR repository URL
ECR_REPO=$(terraform output -raw ecr_repository_url)
ECR_REGISTRY=$(echo ${ECR_REPO} | cut -d'/' -f1)

# Step 3: Login to ECR
echo ""
echo "Step 3: Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}

# Step 4: Build and push Docker image
echo ""
echo "Step 4: Building and pushing Docker image..."
docker buildx build \
  --platform linux/amd64 \
  --provenance=false \
  --output type=image,name=${ECR_REPO}:${IMAGE_TAG},push=true \
  "$PROCESSOR_DIR"

# Step 5: Deploy infrastructure
echo ""
echo "Step 5: Deploying infrastructure..."
terraform apply -auto-approve

echo ""
echo "=== Deployment Complete ==="
terraform output test_commands
