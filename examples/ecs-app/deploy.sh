#!/bin/bash
set -e

echo "=== ECS App Deployment ==="
echo ""

# Step 1: Initialize Terraform
echo "1. Initializing Terraform..."
terraform init

# Step 2: Apply infrastructure
echo ""
echo "2. Applying Terraform configuration..."
terraform apply -auto-approve

# Step 3: Get ECR repository URL
echo ""
echo "3. Getting ECR repository URL..."
ECR_URL=$(terraform output -raw ecr_repository_url)
echo "ECR Repository: ${ECR_URL}"

# Step 4: Build and push Docker image
echo ""
echo "4. Building and pushing Docker image..."
./build-and-push.sh

# Step 5: Force new deployment
echo ""
echo "5. Forcing ECS service update..."
CLUSTER_NAME=$(terraform output -raw ecs_cluster_name)
SERVICE_NAME=$(terraform output -raw ecs_service_name)
aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --force-new-deployment > /dev/null

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Application URL: $(terraform output -raw alb_dns_name)"
echo ""
echo "Test with:"
echo "  curl http://$(terraform output -raw alb_dns_name)"
