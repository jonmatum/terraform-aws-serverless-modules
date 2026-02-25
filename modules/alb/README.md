# Terraform AWS ALB Module

Application Load Balancer module for ECS services.

## Usage

```hcl
module "alb" {
  source = "github.com/jonmatum/aws-ecs-poc//modules/alb?ref=modules/alb/v0.1.0"

  name              = "my-alb"
  vpc_id            = "vpc-xxxxx"
  subnet_ids        = ["subnet-xxxxx", "subnet-yyyyy"]
  target_port       = 8000
  health_check_path = "/health"
}
```
