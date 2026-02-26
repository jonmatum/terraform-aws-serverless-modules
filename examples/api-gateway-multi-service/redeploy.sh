#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

AWS_REGION=${AWS_REGION:-us-east-1}
IMAGE_TAG=${IMAGE_TAG:-$(git rev-parse --short HEAD 2>/dev/null || date +%s)}
SERVICE=${1:-all}  # all, fastapi, or mcp

echo "=== Multi-Service Redeployment ==="
echo "Region: $AWS_REGION"
echo "Image Tag: $IMAGE_TAG"
echo "Service: $SERVICE"
echo ""

# Get ECR URLs and cluster info
FASTAPI_ECR_URL=$(terraform output -raw fastapi_ecr_url)
MCP_ECR_URL=$(terraform output -raw mcp_ecr_url)
CLUSTER_NAME=$(terraform output -raw ecs_fastapi_cluster_name)

# Login to ECR
echo "Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $FASTAPI_ECR_URL

# Function to build and deploy a service
deploy_service() {
  local service_name=$1
  local service_dir=$2
  local ecr_url=$3
  local ecs_service=$4

  echo ""
  echo "=== Deploying $service_name ==="

  cd $service_dir
  echo "Building image..."
  docker build --platform linux/amd64 -t $ecr_url:$IMAGE_TAG -t $ecr_url:latest .

  echo "Pushing image..."
  docker push $ecr_url:$IMAGE_TAG
  docker push $ecr_url:latest
  cd ..

  echo "Forcing ECS service update..."
  aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $ecs_service \
    --force-new-deployment \
    --region $AWS_REGION \
    --no-cli-pager > /dev/null

  echo "$service_name deployment initiated"
}

# Deploy based on service parameter
if [ "$SERVICE" = "all" ] || [ "$SERVICE" = "fastapi" ]; then
  deploy_service "FastAPI" "fastapi-service" "$FASTAPI_ECR_URL" "multi-service-fastapi-service"
fi

if [ "$SERVICE" = "all" ] || [ "$SERVICE" = "mcp" ]; then
  deploy_service "MCP" "mcp-service" "$MCP_ECR_URL" "multi-service-mcp-service"
fi

echo ""
echo "=== Redeployment Complete ==="
echo "Monitor services:"
echo "  aws ecs describe-services --cluster $CLUSTER_NAME --services multi-service-fastapi-service multi-service-mcp-service --region $AWS_REGION"
