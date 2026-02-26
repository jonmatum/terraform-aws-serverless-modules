#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

AWS_REGION=${AWS_REGION:-us-east-1}
IMAGE_TAG=${IMAGE_TAG:-latest}

echo "=== ECS App Deployment ==="
echo "Region: $AWS_REGION"
echo "Image Tag: $IMAGE_TAG"
echo ""

# Check prerequisites
if ! command -v aws &> /dev/null; then
    echo "Error: AWS CLI is not installed"
    exit 1
fi

if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed"
    exit 1
fi

# Step 1: Initialize Terraform
echo "Step 1: Initializing Terraform..."
terraform init

# Step 2: Create ECR and supporting infrastructure
echo ""
echo "Step 2: Creating ECR repository and supporting infrastructure..."
terraform apply -auto-approve -target=module.ecr -target=module.vpc -target=module.alb -target=aws_cloudwatch_log_group.this -target=aws_iam_role.ecs_execution -target=aws_iam_role_policy_attachment.ecs_execution -target=aws_iam_role_policy.ecs_execution_logs -target=aws_security_group.ecs_tasks

# Step 3: Build and push Docker image
echo ""
echo "Step 3: Building and pushing Docker image..."
./build-and-push.sh

# Step 4: Deploy ECS service
echo ""
echo "Step 4: Deploying ECS service..."
terraform apply -auto-approve

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Application URL: http://$(terraform output -raw alb_dns_name)"
echo ""
echo "Test with:"
echo "  curl http://$(terraform output -raw alb_dns_name)"
