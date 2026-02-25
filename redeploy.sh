#!/bin/bash
set -e

cd examples/ecs-app

# Use git commit SHA or timestamp as tag
IMAGE_TAG=${1:-$(git rev-parse --short HEAD 2>/dev/null || date +%s)}

echo "Deploying with image tag: $IMAGE_TAG"

# Get ECR URL
ECR_URL=$(terraform output -raw ecr_repository_url)
AWS_REGION=$(terraform output -raw aws_region)

# Login to ECR
echo "Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL

# Build and push
echo "Building image..."
docker build --platform linux/amd64 -t $ECR_URL:$IMAGE_TAG -t $ECR_URL:latest .

echo "Pushing image..."
docker push $ECR_URL:$IMAGE_TAG
docker push $ECR_URL:latest

# Force new deployment
echo "Forcing ECS service update..."
CLUSTER_NAME=$(terraform output -raw ecs_cluster_id | cut -d'/' -f2)
SERVICE_NAME=$(terraform output -raw ecs_service_name)

aws ecs update-service \
  --cluster $CLUSTER_NAME \
  --service $SERVICE_NAME \
  --force-new-deployment \
  --region $AWS_REGION \
  --no-cli-pager > /dev/null

echo ""
echo "=== Deployment Complete ==="
echo "Image Tag: $IMAGE_TAG"
echo "Monitor deployment:"
echo "  aws ecs describe-services --cluster $CLUSTER_NAME --services $SERVICE_NAME --region $AWS_REGION"
