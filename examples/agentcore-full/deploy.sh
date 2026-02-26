#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}AgentCore Full Example Deployment${NC}"
echo "=================================="

# Check prerequisites
command -v aws >/dev/null 2>&1 || { echo -e "${RED}AWS CLI required${NC}"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo -e "${RED}Docker required${NC}"; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo -e "${RED}Terraform required${NC}"; exit 1; }

# Get AWS account and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=${AWS_REGION:-us-east-1}

echo -e "${YELLOW}AWS Account: ${AWS_ACCOUNT_ID}${NC}"
echo -e "${YELLOW}AWS Region: ${AWS_REGION}${NC}"

# Initialize Terraform
echo -e "\n${GREEN}1. Initializing Terraform...${NC}"
cd terraform
terraform init

# Apply infrastructure (without images first)
echo -e "\n${GREEN}2. Creating infrastructure...${NC}"
terraform apply -auto-approve

# Get ECR URLs
ECR_ECS=$(terraform output -raw ecr_ecs_url 2>/dev/null || echo "")
ECR_LAMBDA=$(terraform output -raw ecr_lambda_url 2>/dev/null || echo "")

if [ -z "$ECR_ECS" ] || [ -z "$ECR_LAMBDA" ]; then
    echo -e "${RED}Failed to get ECR URLs${NC}"
    exit 1
fi

# Login to ECR
echo -e "\n${GREEN}3. Logging into ECR...${NC}"
aws ecr get-login-password --region $AWS_REGION | \
    docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Build and push ECS MCP server
echo -e "\n${GREEN}4. Building ECS MCP server...${NC}"
cd ../mcp-server-ecs
docker build -t $ECR_ECS:latest .
docker push $ECR_ECS:latest

# Build and push Lambda MCP server
echo -e "\n${GREEN}5. Building Lambda MCP server...${NC}"
cd ../mcp-server-lambda
docker build -t $ECR_LAMBDA:latest .
docker push $ECR_LAMBDA:latest

# Build and push Action Lambda
echo -e "\n${GREEN}6. Building Action Lambda...${NC}"
cd ../action-lambda
docker build -t $ECR_LAMBDA:actions .
docker push $ECR_LAMBDA:actions

# Update ECS service
echo -e "\n${GREEN}7. Updating ECS service...${NC}"
cd ../terraform
aws ecs update-service \
    --cluster $(terraform output -raw ecs_cluster_name) \
    --service $(terraform output -raw ecs_service_name) \
    --force-new-deployment \
    --region $AWS_REGION >/dev/null

# Update Lambda functions
echo -e "\n${GREEN}8. Updating Lambda functions...${NC}"
aws lambda update-function-code \
    --function-name $(terraform output -raw lambda_mcp_name) \
    --image-uri $ECR_LAMBDA:latest \
    --region $AWS_REGION >/dev/null

aws lambda update-function-code \
    --function-name $(terraform output -raw lambda_actions_name) \
    --image-uri $ECR_LAMBDA:actions \
    --region $AWS_REGION >/dev/null

# Upload documents to Knowledge Base
echo -e "\n${GREEN}9. Uploading documents to Knowledge Base...${NC}"
KB_BUCKET=$(terraform output -raw kb_bucket_name)
aws s3 sync ../docs s3://$KB_BUCKET/docs/ --delete

# Sync Knowledge Base
echo -e "\n${GREEN}10. Syncing Knowledge Base...${NC}"
KB_ID=$(terraform output -raw knowledge_base_id)
DS_ID=$(terraform output -raw data_source_id)

INGESTION_JOB=$(aws bedrock-agent start-ingestion-job \
    --knowledge-base-id $KB_ID \
    --data-source-id $DS_ID \
    --region $AWS_REGION \
    --output json)

INGESTION_JOB_ID=$(echo $INGESTION_JOB | jq -r '.ingestionJob.ingestionJobId')
echo "Ingestion job started: $INGESTION_JOB_ID"

# Wait for ingestion to complete
echo "Waiting for ingestion to complete..."
while true; do
    STATUS=$(aws bedrock-agent get-ingestion-job \
        --knowledge-base-id $KB_ID \
        --data-source-id $DS_ID \
        --ingestion-job-id $INGESTION_JOB_ID \
        --region $AWS_REGION \
        --query 'ingestionJob.status' \
        --output text)
    
    if [ "$STATUS" = "COMPLETE" ]; then
        echo -e "${GREEN}Ingestion complete!${NC}"
        break
    elif [ "$STATUS" = "FAILED" ]; then
        echo -e "${RED}Ingestion failed${NC}"
        break
    fi
    
    echo "Status: $STATUS"
    sleep 10
done

# Display outputs
echo -e "\n${GREEN}Deployment Complete!${NC}"
echo "===================="
terraform output test_commands

echo -e "\n${YELLOW}Next steps:${NC}"
echo "1. Confirm SNS subscription email (if using alarms)"
echo "2. Test the Gateway with the commands above"
echo "3. Try asking the Agent questions about products or returns"
echo "4. Check CloudWatch Logs for debugging"
