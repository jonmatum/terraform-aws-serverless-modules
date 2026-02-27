#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$SCRIPT_DIR/terraform"

AWS_REGION=${AWS_REGION:-us-east-1}

echo "=== SNS Fan-out Example Deployment ==="
echo "Region: $AWS_REGION"
echo ""

# Change to Terraform directory
cd "$TERRAFORM_DIR"

# Step 1: Initialize Terraform
echo "Step 1: Initializing Terraform..."
terraform init

# Step 2: Deploy infrastructure
echo ""
echo "Step 2: Deploying infrastructure..."
terraform apply -auto-approve

echo ""
echo "=== Deployment Complete ==="
terraform output test_commands
