#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"
APP_DIR="$SCRIPT_DIR/app"

IMAGE_TAG=${1:-latest}
AWS_REGION=${AWS_REGION:-us-east-1}

echo "=== ECS App Deployment ==="
echo "Region: $AWS_REGION"
echo "Image Tag: $IMAGE_TAG"
echo ""

# Change to Terraform directory
cd "$TERRAFORM_DIR"

# Initialize Terraform (always run to ensure modules are up to date)
echo "Initializing Terraform..."
terraform init

# Apply infrastructure
echo "Applying infrastructure..."
terraform apply -auto-approve

# Get ECR repository URL
ECR_REPO=$(terraform output -raw ecr_repository_url)
APP_NAME=$(basename "$ECR_REPO")

# Build and push image
echo ""
echo "Building and pushing Docker image..."
docker build --platform linux/amd64 -t ${APP_NAME}:${IMAGE_TAG} "$APP_DIR"
docker tag ${APP_NAME}:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}

aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
docker push ${ECR_REPO}:${IMAGE_TAG}

# Force ECS update if service exists
CLUSTER=$(terraform output -raw ecs_cluster_name)
SERVICE=$(terraform output -raw ecs_service_name)

if aws ecs describe-services --region ${AWS_REGION} --cluster ${CLUSTER} --services ${SERVICE} --query 'services[0].status' --output text 2>/dev/null | grep -q ACTIVE; then
  echo ""
  echo "Updating ECS service..."
  aws ecs update-service --region ${AWS_REGION} --cluster ${CLUSTER} --service ${SERVICE} --force-new-deployment --no-cli-pager > /dev/null
fi

echo ""
echo "=== Deployment Complete ==="
ALB_URL=$(terraform output -raw alb_dns_name)
echo "Application URL: http://${ALB_URL}"
