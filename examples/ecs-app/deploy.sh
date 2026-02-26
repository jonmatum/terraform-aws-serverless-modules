#!/bin/bash
set -e

echo "=== ECS App Deployment ==="
echo ""

# Step 1: Initialize Terraform
echo "1. Initializing Terraform..."
terraform init

# Step 2: Create ECR and supporting infrastructure (but not ECS service yet)
echo ""
echo "2. Creating ECR repository..."
terraform apply -auto-approve -target=module.ecr -target=module.vpc -target=module.alb -target=aws_cloudwatch_log_group.this -target=aws_iam_role.ecs_execution -target=aws_iam_role_policy_attachment.ecs_execution -target=aws_iam_role_policy.ecs_execution_logs -target=aws_security_group.ecs_tasks

# Step 3: Build and push Docker image
echo ""
echo "3. Building and pushing Docker image..."
./build-and-push.sh

# Step 4: Deploy ECS service now that image exists
echo ""
echo "4. Deploying ECS service..."
terraform apply -auto-approve

echo ""
echo "✅ Deployment complete!"
echo ""
echo "Application URL: http://$(terraform output -raw alb_dns_name)"
echo ""
echo "Test with:"
echo "  curl http://$(terraform output -raw alb_dns_name)"
