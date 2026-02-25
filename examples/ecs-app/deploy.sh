#!/bin/bash
set -e

echo "=== ECS App Deployment ==="
echo ""

# Step 1: Initialize Terraform
echo "1. Initializing Terraform..."
terraform init

# Step 2: Build and push Docker image (ECR repo should exist or will be created)
echo ""
echo "2. Building and pushing Docker image..."
./build-and-push.sh

# Step 3: Deploy all infrastructure
echo ""
echo "3. Deploying infrastructure..."
terraform apply -auto-approve

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Application URL: http://$(terraform output -raw alb_dns_name)"
echo ""
echo "Test with:"
echo "  curl http://$(terraform output -raw alb_dns_name)"
