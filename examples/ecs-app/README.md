# FastAPI ECS Example

Simple FastAPI application deployed to ECS with ALB.

## Deployment Steps

### 1. Create Infrastructure (ECR only)

```bash
cd examples/ecs-app
terraform init
terraform apply -target=module.ecr
```

### 2. Build and Push Docker Image

```bash
# Get ECR repository URL from output
ECR_URL=$(terraform output -raw ecr_repository_url)

# Login to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ECR_URL

# Build and push
docker build -t $ECR_URL:latest .
docker push $ECR_URL:latest
```

### 3. Deploy ECS Service

```bash
terraform apply
```

### 4. Access Application

```bash
# Get ALB DNS name
terraform output alb_dns_name

# Test
curl http://$(terraform output -raw alb_dns_name)
```

## Redeployment

After making code changes:

```bash
# From project root
./redeploy.sh

# Or with specific tag
./redeploy.sh v1.2.3
```

This will:
1. Build new Docker image with tag (git SHA or timestamp)
2. Push to ECR with new tag + update `latest`
3. Force ECS service to deploy new tasks

## Local Development

```bash
pip install -r requirements.txt
uvicorn app:app --reload
```

