# Terraform AWS API Gateway HTTP API Module

API Gateway HTTP API (v2) module with VPC Link support.

## Features

- API Gateway HTTP API (v2) with lower cost and latency
- VPC Link for private integrations
- CORS configuration
- Custom domain support
- JWT authorizers
- Throttling and rate limiting
- CloudWatch logging
- X-Ray tracing

## Usage

```hcl
module "api_gateway" {
  source  = "jonmatum/serverless-modules/aws//modules/api-gateway"
  version = "2.0.1"

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

## Examples

- [api-gateway-multi-service](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/api-gateway-multi-service) - Multi-service architecture
- [crud-api-http](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/crud-api-http) - CRUD API with HTTP API

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.34.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_apigatewayv2_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) | resource |
| [aws_apigatewayv2_integration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration) | resource |
| [aws_apigatewayv2_route.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_stage.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage) | resource |
| [aws_apigatewayv2_vpc_link.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_vpc_link) | resource |
| [aws_cloudwatch_log_group.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_access_logs"></a> [enable\_access\_logs](#input\_enable\_access\_logs) | Enable API Gateway access logs | `bool` | `true` | no |
| <a name="input_enable_throttling"></a> [enable\_throttling](#input\_enable\_throttling) | Enable API Gateway throttling | `bool` | `true` | no |
| <a name="input_enable_xray_tracing"></a> [enable\_xray\_tracing](#input\_enable\_xray\_tracing) | Enable X-Ray tracing | `bool` | `true` | no |
| <a name="input_integrations"></a> [integrations](#input\_integrations) | Map of route integrations | <pre>map(object({<br/>    method          = string<br/>    route_key       = string<br/>    connection_type = string<br/>    connection_id   = optional(string)<br/>    uri             = string<br/>  }))</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for API Gateway resources | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_throttle_burst_limit"></a> [throttle\_burst\_limit](#input\_throttle\_burst\_limit) | Throttle burst limit | `number` | `5000` | no |
| <a name="input_throttle_rate_limit"></a> [throttle\_rate\_limit](#input\_throttle\_rate\_limit) | Throttle rate limit (requests per second) | `number` | `10000` | no |
| <a name="input_vpc_link_security_group_ids"></a> [vpc\_link\_security\_group\_ids](#input\_vpc\_link\_security\_group\_ids) | Security group IDs for VPC Link | `list(string)` | n/a | yes |
| <a name="input_vpc_link_subnet_ids"></a> [vpc\_link\_subnet\_ids](#input\_vpc\_link\_subnet\_ids) | Subnet IDs for VPC Link | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_endpoint"></a> [api\_endpoint](#output\_api\_endpoint) | API Gateway endpoint URL |
| <a name="output_api_id"></a> [api\_id](#output\_api\_id) | API Gateway ID |
| <a name="output_stage_arn"></a> [stage\_arn](#output\_stage\_arn) | ARN of the API Gateway stage |
| <a name="output_vpc_link_id"></a> [vpc\_link\_id](#output\_vpc\_link\_id) | VPC Link ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
