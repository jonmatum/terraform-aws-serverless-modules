# Terraform AWS API Gateway REST API Module

API Gateway REST API (v1) module with VPC Link and NLB support.

## Features

- API Gateway REST API (v1) with full feature set
- VPC Link for private integrations (requires NLB)
- OpenAPI/Swagger specification support
- API keys and usage plans
- Request/response validation
- Request/response transformation
- Custom authorizers (Lambda, Cognito)
- CloudWatch logging and X-Ray tracing

## Architecture

API Gateway REST API v1 requires NLB for VPC Link integration (AWS limitation).

**With ALB (OpenAPI mode):**
```
API Gateway → VPC Link → NLB → ALB → Backend
```

**Direct to backend (Legacy mode):**
```
API Gateway → VPC Link → NLB → Backend
```

## Usage

```hcl
module "api_gateway_rest" {
  source  = "jonmatum/serverless-modules/aws//modules/api-gateway-v1"
  version = "2.0.1"

  name        = "my-rest-api"
  description = "My REST API"

  # OpenAPI specification
  openapi_spec = file("${path.module}/openapi.json")
}
```

## Examples

- [crud-api-rest](../../examples/crud-api-rest/) - CRUD API with REST API
- [rest-api-service](../../examples/rest-api-service/) - REST API service

## Well-Architected Considerations

- **Cost**: NLB adds ~$16/month. Consider HTTP API (v2) if you don't need REST API v1 features
- **Performance**: NLB → ALB adds 1-3ms latency
- **Reliability**: Cross-zone load balancing enabled by default
- **Security**: Private integration via VPC Link

## Usage

### OpenAPI Mode (with ALB)

```hcl
module "api_gateway_v1" {
  source = "../../modules/api-gateway-v1"

  name                = "my-api"
  vpc_link_subnet_ids = ["subnet-xxxxx", "subnet-yyyyy"]
  vpc_id              = "vpc-xxxxx"
  alb_arn             = "arn:aws:elasticloadbalancing:..."
  health_check_path   = "/health"

  openapi_spec = file("swagger.json")
}
```

### Legacy Mode (direct integration)

```hcl
module "api_gateway_v1" {
  source = "../../modules/api-gateway-v1"

  name                = "my-api"
  vpc_link_subnet_ids = ["subnet-xxxxx", "subnet-yyyyy"]

  integrations = {
    api = {
      http_method     = "ANY"
      integration_uri = "http://nlb-dns-name"
    }
  }
}
```
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
| [aws_api_gateway_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_account) | resource |
| [aws_api_gateway_deployment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_integration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_method.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_settings.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_resource.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_rest_api.legacy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_rest_api.openapi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_api_gateway_vpc_link.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_vpc_link) | resource |
| [aws_cloudwatch_log_group.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.api_gateway_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.api_gateway_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_lb.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb) | resource |
| [aws_lb_listener.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_target_group.nlb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group_attachment.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_arn"></a> [alb\_arn](#input\_alb\_arn) | ARN of the ALB to attach to NLB (required when using OpenAPI mode with ALB) | `string` | `null` | no |
| <a name="input_enable_access_logs"></a> [enable\_access\_logs](#input\_enable\_access\_logs) | Enable API Gateway access logs | `bool` | `true` | no |
| <a name="input_enable_deletion_protection"></a> [enable\_deletion\_protection](#input\_enable\_deletion\_protection) | Enable deletion protection for NLB | `bool` | `false` | no |
| <a name="input_enable_nlb_access_logs"></a> [enable\_nlb\_access\_logs](#input\_enable\_nlb\_access\_logs) | Enable NLB access logs | `bool` | `false` | no |
| <a name="input_enable_xray_tracing"></a> [enable\_xray\_tracing](#input\_enable\_xray\_tracing) | Enable X-Ray tracing | `bool` | `true` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Health check path for NLB target group | `string` | `"/health"` | no |
| <a name="input_integrations"></a> [integrations](#input\_integrations) | Map of integrations (legacy mode, ignored if openapi\_spec is provided) | <pre>map(object({<br/>    http_method     = string<br/>    integration_uri = string<br/>  }))</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for API Gateway resources | `string` | n/a | yes |
| <a name="input_nlb_access_logs_bucket"></a> [nlb\_access\_logs\_bucket](#input\_nlb\_access\_logs\_bucket) | S3 bucket for NLB access logs | `string` | `null` | no |
| <a name="input_openapi_spec"></a> [openapi\_spec](#input\_openapi\_spec) | OpenAPI/Swagger specification (JSON string). If provided, uses OpenAPI mode instead of integrations. | `string` | `null` | no |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | Stage name | `string` | `"prod"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_throttle_burst_limit"></a> [throttle\_burst\_limit](#input\_throttle\_burst\_limit) | Throttle burst limit | `number` | `5000` | no |
| <a name="input_throttle_rate_limit"></a> [throttle\_rate\_limit](#input\_throttle\_rate\_limit) | Throttle rate limit (requests per second) | `number` | `10000` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID for NLB target group (required when using OpenAPI mode with ALB) | `string` | `null` | no |
| <a name="input_vpc_link_subnet_ids"></a> [vpc\_link\_subnet\_ids](#input\_vpc\_link\_subnet\_ids) | Subnet IDs for VPC Link | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_endpoint"></a> [api\_endpoint](#output\_api\_endpoint) | API Gateway endpoint URL |
| <a name="output_api_id"></a> [api\_id](#output\_api\_id) | API Gateway REST API ID |
| <a name="output_nlb_arn"></a> [nlb\_arn](#output\_nlb\_arn) | Network Load Balancer ARN |
| <a name="output_nlb_dns_name"></a> [nlb\_dns\_name](#output\_nlb\_dns\_name) | Network Load Balancer DNS name |
| <a name="output_stage_arn"></a> [stage\_arn](#output\_stage\_arn) | ARN of the API Gateway stage |
| <a name="output_vpc_link_id"></a> [vpc\_link\_id](#output\_vpc\_link\_id) | VPC Link ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
