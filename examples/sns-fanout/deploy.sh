#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"

AWS_REGION=${AWS_REGION:-us-east-1}

echo "=== SNS Fan-out Example Deployment ==="
echo "Region: $AWS_REGION"
echo ""

cd "$TERRAFORM_DIR"

echo "Initializing Terraform..."
terraform init

echo ""
echo "Deploying infrastructure..."
terraform apply -auto-approve

echo ""
echo "=== Deployment Complete ==="
terraform output test_commands
