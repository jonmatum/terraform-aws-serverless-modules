#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Generate image tag (use provided tag, git SHA, or timestamp)
if [ -n "$1" ]; then
  IMAGE_TAG="$1"
elif git rev-parse --git-dir > /dev/null 2>&1; then
  IMAGE_TAG=$(git rev-parse --short HEAD)
else
  IMAGE_TAG=$(date +%Y%m%d-%H%M%S)
fi

AWS_REGION=${AWS_REGION:-us-east-1}

echo "=== ECS App Redeployment ==="
echo "Region: $AWS_REGION"
echo "Image Tag: $IMAGE_TAG"
echo ""

# Step 1: Build and push with new tag
echo "Step 1: Building and pushing image..."
export IMAGE_TAG
./build-and-push.sh

# Step 2: Tag as latest
echo ""
echo "Step 2: Updating 'latest' tag..."
ECR_REPO=$(terraform output -raw ecr_repository_url)
APP_NAME=$(basename "$ECR_REPO")

docker tag ${APP_NAME}:${IMAGE_TAG} ${ECR_REPO}:latest
docker push ${ECR_REPO}:latest

# Step 3: Force ECS service update
echo ""
echo "Step 3: Forcing ECS service update..."
CLUSTER=$(terraform output -raw ecs_cluster_name)
SERVICE=$(terraform output -raw ecs_service_name)

aws ecs update-service \
  --region ${AWS_REGION} \
  --cluster ${CLUSTER} \
  --service ${SERVICE} \
  --force-new-deployment \
  --no-cli-pager > /dev/null

echo ""
echo "=== Redeployment Complete ==="
echo "Image tags: ${IMAGE_TAG}, latest"
