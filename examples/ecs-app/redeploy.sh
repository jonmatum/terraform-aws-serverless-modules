#!/bin/bash
set -e

# Generate image tag (use provided tag, git SHA, or timestamp)
if [ -n "$1" ]; then
  IMAGE_TAG="$1"
elif git rev-parse --git-dir > /dev/null 2>&1; then
  IMAGE_TAG=$(git rev-parse --short HEAD)
else
  IMAGE_TAG=$(date +%Y%m%d-%H%M%S)
fi

echo "=== Redeploying with tag: ${IMAGE_TAG} ==="
echo ""

# Build and push with new tag
echo "1. Building and pushing image..."
export IMAGE_TAG
./build-and-push.sh

# Also tag as latest
echo ""
echo "2. Updating 'latest' tag..."
ECR_REPO=$(terraform output -raw ecr_repository_url)
APP_NAME=$(basename "$ECR_REPO")

docker tag ${APP_NAME}:${IMAGE_TAG} ${ECR_REPO}:latest
docker push ${ECR_REPO}:latest

# Force ECS service update
echo ""
echo "3. Forcing ECS service update..."
CLUSTER=$(terraform output -raw ecs_cluster_name)
SERVICE=$(terraform output -raw ecs_service_name)
AWS_REGION=$(terraform output -raw aws_region)
aws ecs update-service --region ${AWS_REGION} --cluster ${CLUSTER} --service ${SERVICE} --force-new-deployment > /dev/null

echo ""
echo "✅ Redeployment complete!"
echo "   Image tags: ${IMAGE_TAG}, latest"
