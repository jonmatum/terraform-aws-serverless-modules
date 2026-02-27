#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"
APP_DIR="$SCRIPT_DIR/app"

IMAGE_TAG=${1:-latest}
AWS_REGION=${AWS_REGION:-us-east-1}

echo "=== Lambda Function Deployment ==="
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

# Get ECR repository URL
ECR_REPO=$(terraform output -raw ecr_repository_url)

# Step 3: Login to ECR
echo ""
echo "Step 3: Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}

# Step 4: Build and push Docker image
echo ""
echo "Step 4: Building and pushing Docker image..."
docker buildx build \
  --platform linux/amd64 \
  --provenance=false \
  --output type=image,name=${ECR_REPO}:${IMAGE_TAG},push=true \
  "$APP_DIR"

# Step 5: Deploy infrastructure
echo ""
echo "Step 5: Deploying infrastructure..."
terraform apply -auto-approve

# Step 6: Force Lambda to pull new image
echo ""
echo "Step 6: Forcing Lambda function update..."
FUNCTION_NAME=$(terraform output -raw function_name)
aws lambda update-function-code \
  --function-name ${FUNCTION_NAME} \
  --image-uri ${ECR_REPO}:${IMAGE_TAG} \
  --region ${AWS_REGION} > /dev/null

echo ""
echo "=== Deployment Complete ==="
FUNCTION_URL=$(terraform output -raw function_url)
echo "Function URL: ${FUNCTION_URL}"
echo ""
echo "Test endpoints:"
echo "  curl ${FUNCTION_URL}"
echo "  curl ${FUNCTION_URL}health"
echo "  curl ${FUNCTION_URL}info"
