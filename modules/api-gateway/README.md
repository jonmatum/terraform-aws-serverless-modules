# Terraform AWS API Gateway HTTP API Module

API Gateway HTTP API (v2) module with VPC Link support.

## Usage

```hcl
module "api_gateway" {
  source = "github.com/jonmatum/aws-ecs-poc//modules/api-gateway?ref=modules/api-gateway/v0.1.0"

  name                        = "my-api"
  vpc_link_subnet_ids         = ["subnet-xxxxx", "subnet-yyyyy"]
  vpc_link_security_group_ids = ["sg-xxxxx"]

  integrations = {
    api = {
      method          = "ANY"
      route_key       = "ANY /api/{proxy+}"
      connection_type = "VPC_LINK"
      uri             = "http://internal-alb.local"
    }
  }
}
```
