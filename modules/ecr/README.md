# Terraform AWS ECR Module

Elastic Container Registry module for storing Docker images.

## Usage

```hcl
module "ecr" {
  source = "github.com/jonmatum/aws-ecs-poc//modules/ecr?ref=modules/ecr/v0.1.0"

  repository_name      = "my-app"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
}
```
