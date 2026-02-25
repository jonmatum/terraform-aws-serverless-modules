# Terraform AWS ECS Fargate Module

ECS Fargate service module with cluster, task definition, and service.

## Usage

```hcl
module "ecs" {
  source = "github.com/jonmatum/aws-ecs-poc//modules/ecs?ref=modules/ecs/v0.1.0"

  cluster_name       = "my-cluster"
  task_family        = "my-app"
  service_name       = "my-service"
  container_name     = "app"
  container_image    = "123456789.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
  container_port     = 8000
  execution_role_arn = aws_iam_role.ecs_execution.arn
  subnet_ids         = ["subnet-xxxxx", "subnet-yyyyy"]
  security_group_ids = ["sg-xxxxx"]
  log_group_name     = "/ecs/my-app"
  aws_region         = "us-east-1"
}
```
