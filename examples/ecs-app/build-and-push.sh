#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Get ECR URL from Terraform output
ECR_REPO=$(terraform output -raw ecr_repository_url 2>/dev/null)
if [ -z "$ECR_REPO" ]; then
  echo "Error: ECR repository not found. Run 'terraform apply' first."
  exit 1
fi

AWS_REGION=$(terraform output -raw aws_region 2>/dev/null || echo "us-east-1")
IMAGE_TAG=${IMAGE_TAG:-latest}
APP_NAME=$(basename "$ECR_REPO")

echo "Building Docker image for linux/amd64..."
docker build --platform linux/amd64 -t ${APP_NAME}:${IMAGE_TAG} .

echo "Tagging image for ECR..."
docker tag ${APP_NAME}:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}

echo "Logging in to ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}

echo "Pushing image to ECR..."
docker push ${ECR_REPO}:${IMAGE_TAG}

echo "Image pushed successfully: ${ECR_REPO}:${IMAGE_TAG}"
