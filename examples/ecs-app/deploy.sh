#!/bin/bash
set -e

echo "=== ECS App Deployment ==="
echo ""

# Step 1: Initialize Terraform
echo "1. Initializing Terraform..."
terraform init

# Step 2: Create ECR repository first
echo ""
echo "2. Creating ECR repository..."
terraform apply -target=module.ecr -auto-approve

# Step 3: Build and push Docker image
echo ""
echo "3. Building and pushing Docker image..."
./build-and-push.sh

# Step 4: Deploy remaining infrastructure
echo ""
echo "4. Deploying ECS infrastructure..."
terraform apply -auto-approve

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Application URL: http://$(terraform output -raw alb_dns_name)"
echo ""
echo "Test with:"
echo "  curl http://$(terraform output -raw alb_dns_name)"
