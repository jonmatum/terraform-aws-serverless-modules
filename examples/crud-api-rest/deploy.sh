#!/bin/bash
set -e

echo "🚀 Deploying CRUD API (REST API with Swagger)"
echo "=============================================="

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed"
    exit 1
fi

# Initialize Terraform
echo "📦 Initializing Terraform..."
terraform init

# Apply infrastructure (without Docker image first)
echo "🏗️  Creating infrastructure..."
terraform apply -auto-approve

# Get ECR repository URL
ECR_REPO=$(terraform output -raw ecr_repository_url)
AWS_REGION=$(terraform output -json | jq -r '.aws_region.value // "us-east-1"')
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Build and push Docker image
echo "🐳 Building and pushing Docker image..."
cd fastapi-app

# Login to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build image
docker build -t crud-api-rest:latest .

# Tag and push
docker tag crud-api-rest:latest $ECR_REPO:latest
docker push $ECR_REPO:latest

cd ..

# Force new ECS deployment
echo "🔄 Forcing ECS service update..."
CLUSTER_NAME=$(terraform output -raw cluster_name)
SERVICE_NAME=$(terraform output -raw service_name)

aws ecs update-service \
  --cluster $CLUSTER_NAME \
  --service $SERVICE_NAME \
  --force-new-deployment \
  --region $AWS_REGION \
  > /dev/null

# Wait for service to stabilize
echo "⏳ Waiting for ECS service to stabilize (this may take 2-3 minutes)..."
aws ecs wait services-stable \
  --cluster $CLUSTER_NAME \
  --services $SERVICE_NAME \
  --region $AWS_REGION

echo ""
echo "✅ Deployment complete!"
echo "=============================================="
echo ""
terraform output test_commands
