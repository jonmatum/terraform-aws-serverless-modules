#!/bin/bash
set -e

PROJECT_NAME="mcp-agent"
AWS_REGION="${AWS_REGION:-us-east-1}"
IMAGE_TAG="${IMAGE_TAG:-latest}"

echo "=== MCP Agent Runtime Deployment ==="
echo "Project: $PROJECT_NAME"
echo "Region: $AWS_REGION"
echo "Image Tag: $IMAGE_TAG"
echo ""

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Apply infrastructure
echo "Applying Terraform configuration..."
terraform apply -auto-approve

# Get ECR repository URL
ECR_URL=$(terraform output -raw ecr_repository_url)
echo "ECR Repository: $ECR_URL"

# Login to ECR
echo "Logging in to ECR..."
aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $ECR_URL

# Build and push Docker image
echo "Building Docker image..."
cd mcp-server
docker build -t $ECR_URL:$IMAGE_TAG .

echo "Pushing Docker image..."
docker push $ECR_URL:$IMAGE_TAG
cd ..

# Force new deployment
echo "Forcing new ECS deployment..."
CLUSTER_NAME=$(terraform output -raw ecs_cluster_name)
SERVICE_NAME=$(terraform output -raw ecs_service_name)

aws ecs update-service \
  --cluster $CLUSTER_NAME \
  --service $SERVICE_NAME \
  --force-new-deployment \
  --region $AWS_REGION \
  > /dev/null

echo ""
echo "=== Deployment Complete ==="
echo ""
terraform output test_commands
