#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"

IMAGE_TAG=${1:-latest}
AWS_REGION=${AWS_REGION:-us-east-1}

echo "=== AgentCore Full Deployment ==="
echo "Region: $AWS_REGION"
echo "Image Tag: $IMAGE_TAG"
echo ""

# Change to Terraform directory
cd "$TERRAFORM_DIR"

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Apply infrastructure
echo "Applying infrastructure..."
terraform apply -auto-approve

# Get ECR repository URLs
ECR_ECS=$(terraform output -raw ecr_ecs_repository_url)
ECR_LAMBDA=$(terraform output -raw ecr_lambda_repository_url)

# Login to ECR
echo ""
echo "Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_ECS}

# Build and push ECS MCP server
echo ""
echo "Building and pushing ECS MCP server..."
docker buildx build \
  --platform linux/amd64 \
  --provenance=false \
  --output type=image,name=${ECR_ECS}:${IMAGE_TAG},push=true \
  "$SCRIPT_DIR/mcp-server-ecs"

# Build and push Lambda MCP server
echo ""
echo "Building and pushing Lambda MCP server..."
docker buildx build \
  --platform linux/amd64 \
  --provenance=false \
  --output type=image,name=${ECR_LAMBDA}:${IMAGE_TAG},push=true \
  "$SCRIPT_DIR/mcp-server-lambda"

# Build and push Action Lambda
echo ""
echo "Building and pushing Action Lambda..."
ECR_ACTIONS=$(terraform output -raw ecr_actions_repository_url)
docker buildx build \
  --platform linux/amd64 \
  --provenance=false \
  --output type=image,name=${ECR_ACTIONS}:${IMAGE_TAG},push=true \
  "$SCRIPT_DIR/action-lambda"

# Force ECS update if service exists
CLUSTER=$(terraform output -raw ecs_cluster_name)
SERVICE=$(terraform output -raw ecs_service_name)

if aws ecs describe-services --region ${AWS_REGION} --cluster ${CLUSTER} --services ${SERVICE} --query 'services[0].status' --output text 2>/dev/null | grep -q ACTIVE; then
  echo ""
  echo "Updating ECS service..."
  aws ecs update-service --region ${AWS_REGION} --cluster ${CLUSTER} --service ${SERVICE} --force-new-deployment --no-cli-pager > /dev/null
fi

# Sync Knowledge Base documents
echo ""
echo "Syncing Knowledge Base documents..."
KB_BUCKET=$(terraform output -raw kb_bucket_name)
aws s3 sync "$SCRIPT_DIR/docs" s3://${KB_BUCKET}/ --delete

# Start Knowledge Base ingestion
KB_ID=$(terraform output -raw knowledge_base_id)
DS_ID=$(terraform output -raw data_source_id)

echo "Starting Knowledge Base ingestion..."
aws bedrock-agent start-ingestion-job \
  --knowledge-base-id ${KB_ID} \
  --data-source-id ${DS_ID} \
  --region ${AWS_REGION} \
  --no-cli-pager > /dev/null

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Gateway ID: $(terraform output -raw gateway_id)"
echo "Agent ID: $(terraform output -raw agent_id)"
echo "Knowledge Base ID: ${KB_ID}"
echo ""
echo "Test commands:"
echo "  aws bedrock-agent-runtime invoke-agent --agent-id $(terraform output -raw agent_id) --agent-alias-id $(terraform output -raw agent_alias_id) --session-id test-session --input-text 'What is your return policy?'"
