#!/bin/bash
set -e

# Get AWS account ID and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=${AWS_REGION:-us-east-1}
APP_NAME=${APP_NAME:-ecs-app}
IMAGE_TAG=${IMAGE_TAG:-latest}

# ECR repository URL
ECR_REPO="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${APP_NAME}"

echo "Building Docker image..."
docker build -t ${APP_NAME}:${IMAGE_TAG} .

echo "Tagging image for ECR..."
docker tag ${APP_NAME}:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}

echo "Logging in to ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}

echo "Pushing image to ECR..."
docker push ${ECR_REPO}:${IMAGE_TAG}

echo "✅ Image pushed successfully: ${ECR_REPO}:${IMAGE_TAG}"
