#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

AWS_REGION=${AWS_REGION:-us-east-1}
IMAGE_TAG=${IMAGE_TAG:-$(git rev-parse --short HEAD 2>/dev/null || date +%s)}

echo "=== OpenAPI HTTP API Redeployment ==="
echo "Region: $AWS_REGION"
echo "Image Tag: $IMAGE_TAG"

# Get ECR URL and cluster info
ECR_URL=$(terraform output -raw ecr_repository_url)
CLUSTER_NAME=$(terraform output -raw ecs_cluster_name)
SERVICE_NAME=$(terraform output -raw ecs_service_name)

# Login to ECR
echo ""
echo "Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL

# Build and push
echo ""
echo "Building image..."
docker build --platform linux/amd64 -t $ECR_URL:$IMAGE_TAG -t $ECR_URL:latest .

echo "Pushing image..."
docker push $ECR_URL:$IMAGE_TAG
docker push $ECR_URL:latest

# Apply terraform to update API Gateway if spec changed
echo ""
echo "Updating infrastructure..."
terraform apply -auto-approve

# Force ECS update
echo ""
echo "Forcing ECS service update..."
aws ecs update-service \
  --cluster $CLUSTER_NAME \
  --service $SERVICE_NAME \
  --force-new-deployment \
  --region $AWS_REGION \
  --no-cli-pager > /dev/null

echo ""
echo "=== Redeployment Complete ==="
echo "Image Tag: $IMAGE_TAG"
