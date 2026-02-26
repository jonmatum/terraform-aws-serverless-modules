#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"
APP_DIR="$SCRIPT_DIR/mcp-server"

IMAGE_TAG=${1:-latest}
AWS_REGION=${AWS_REGION:-us-east-1}

echo "=== MCP Agent Runtime Deployment ==="
echo "Region: $AWS_REGION"
echo "Image Tag: $IMAGE_TAG"
echo ""

cd "$TERRAFORM_DIR"

echo "Step 1: Initializing Terraform..."
terraform init

echo ""
echo "Step 2: Applying infrastructure..."
terraform apply -auto-approve

ECR_URL=$(terraform output -raw ecr_repository_url)

echo ""
echo "Step 3: Building and pushing Docker image..."
docker build --platform linux/amd64 -t mcp-agent:${IMAGE_TAG} "$APP_DIR"
docker tag mcp-agent:${IMAGE_TAG} ${ECR_URL}:${IMAGE_TAG}
docker tag mcp-agent:${IMAGE_TAG} ${ECR_URL}:latest

aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}
docker push ${ECR_URL}:${IMAGE_TAG}
docker push ${ECR_URL}:latest

echo ""
echo "Step 4: Updating ECS service..."
terraform refresh > /dev/null

CLUSTER=$(terraform output -raw ecs_cluster_name)
SERVICE=$(terraform output -raw ecs_service_name)

aws ecs update-service --region ${AWS_REGION} --cluster ${CLUSTER} --service ${SERVICE} --force-new-deployment --no-cli-pager > /dev/null

echo ""
echo "=== Deployment Complete ==="
echo "ALB DNS: $(terraform output -raw alb_dns_name)"
