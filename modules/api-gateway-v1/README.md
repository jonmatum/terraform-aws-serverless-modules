# Terraform AWS API Gateway REST API Module

API Gateway REST API (v1) module with VPC Link and NLB support.

## Usage

```hcl
module "api_gateway_v1" {
  source = "github.com/jonmatum/aws-ecs-poc//modules/api-gateway-v1?ref=modules/api-gateway-v1/v0.1.0"

  name                        = "my-api"
  vpc_id                      = "vpc-xxxxx"
  vpc_link_subnet_ids         = ["subnet-xxxxx", "subnet-yyyyy"]
  vpc_link_security_group_ids = ["sg-xxxxx"]
  stage_name                  = "prod"

  integrations = {
    api = {
      http_method     = "ANY"
      resource_path   = "api"
      integration_uri = "http://internal-nlb.local"
    }
  }
}
```
