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

cd "$TERRAFORM_DIR"

echo "Initializing Terraform..."
terraform init

echo "Creating ECR repository..."
terraform apply -target=module.ecr -auto-approve

ECR_REPO=$(terraform output -raw ecr_repository_url)

echo ""
echo "Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}

echo ""
echo "Building and pushing Docker image..."
docker buildx build \
  --platform linux/amd64 \
  --provenance=false \
  --output type=image,name=${ECR_REPO}:${IMAGE_TAG},push=true \
  "$PROCESSOR_DIR"

echo ""
echo "Deploying infrastructure..."
terraform apply -auto-approve

echo ""
echo "=== Deployment Complete ==="
terraform output test_commands
