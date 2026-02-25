#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

AWS_REGION=${AWS_REGION:-us-east-1}
IMAGE_TAG=${IMAGE_TAG:-$(git rev-parse --short HEAD 2>/dev/null || date +%s)}

echo "=== OpenAPI HTTP API Redeployment ==="
echo "Region: $AWS_REGION"
echo "Image Tag: $IMAGE_TAG"

# Get ECR URL and cluster info
ECR_URL=$(terraform output -raw ecr_repository_url)
CLUSTER_NAME=$(terraform output -raw api_id | cut -d'/' -f1)
SERVICE_NAME="${var.project_name:-openapi-http-api}-service"

# Login to ECR
echo ""
echo "Logging into ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_URL

# Build and push
echo ""
echo "Building image..."
docker build --platform linux/amd64 -t $ECR_URL:$IMAGE_TAG -t $ECR_URL:latest .

echo "Pushing image..."
docker push $ECR_URL:$IMAGE_TAG
docker push $ECR_URL:latest

# Regenerate OpenAPI spec if app changed
echo ""
echo "Regenerating OpenAPI spec..."
pip3 install -q -r requirements.txt
python3 -c "
import json
from app import app
spec = app.openapi()
with open('openapi.json', 'w') as f:
    json.dump(spec, f, indent=2)
print('OpenAPI spec updated')
"

# Apply terraform to update API Gateway if spec changed
echo ""
echo "Updating API Gateway with new spec..."
terraform apply -auto-approve

echo ""
echo "=== Redeployment Complete ==="
echo "Image Tag: $IMAGE_TAG"
