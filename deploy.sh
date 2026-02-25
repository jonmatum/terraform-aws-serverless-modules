#!/bin/bash
set -e

cd examples/ecs-app

echo "Step 1: Creating ECR repository..."
terraform apply -target=module.ecr -auto-approve

echo "Step 2: Building and pushing Docker image..."
ECR_URL=$(terraform output -raw ecr_repository_url)
AWS_REGION=$(terraform output -raw aws_region || echo "us-east-1")

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL

docker build --platform linux/amd64 -t $ECR_URL:latest .
docker push $ECR_URL:latest

echo "Step 3: Deploying ECS service..."
terraform apply -auto-approve

echo "Done! Access your app at:"
terraform output alb_dns_name
