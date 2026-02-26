# Terraform AWS WAF Module

AWS WAF (Web Application Firewall) module for protecting web applications.

## Features

- AWS WAF v2 with managed and custom rules
- Rate limiting rules
- IP set filtering (allow/block lists)
- Geographic blocking
- SQL injection protection
- XSS protection
- AWS managed rule groups
- CloudWatch metrics and logging

## Usage

```hcl
module "waf" {
  source  = "jonmatum/serverless-modules/aws//modules/waf"
  version = "2.0.1"

  name  = "my-waf"
  scope = "REGIONAL"

  tags = {
    Environment = "production"
  }
}
```

## Examples

- [crud-api-rest](../../examples/crud-api-rest/) - WAF with API Gateway
- [crud-api-http](../../examples/crud-api-http/) - WAF with HTTP API

## Features

- AWS WAF Web ACL configuration
- Managed rule groups support
- Custom rules support
- Rate limiting
- IP set management

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Name of the WAF Web ACL | string | - | yes |
| scope | Scope of the WAF (REGIONAL or CLOUDFRONT) | string | "REGIONAL" | no |
| tags | Tags to apply to resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| web_acl_id | ID of the WAF Web ACL |
| web_acl_arn | ARN of the WAF Web ACL |
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.33.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_wafv2_ip_set.allowed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_ip_set.blocked](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_ip_set) | resource |
| [aws_wafv2_web_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [aws_wafv2_web_acl_logging_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_ip_addresses"></a> [allowed\_ip\_addresses](#input\_allowed\_ip\_addresses) | List of allowed IP addresses/CIDR blocks | `list(string)` | `[]` | no |
| <a name="input_blocked_countries"></a> [blocked\_countries](#input\_blocked\_countries) | List of country codes to block (e.g., ['CN', 'RU']) | `list(string)` | `[]` | no |
| <a name="input_blocked_ip_addresses"></a> [blocked\_ip\_addresses](#input\_blocked\_ip\_addresses) | List of blocked IP addresses/CIDR blocks | `list(string)` | `[]` | no |
| <a name="input_enable_geo_blocking"></a> [enable\_geo\_blocking](#input\_enable\_geo\_blocking) | Enable geographic blocking | `bool` | `false` | no |
| <a name="input_enable_ip_reputation"></a> [enable\_ip\_reputation](#input\_enable\_ip\_reputation) | Enable AWS managed IP reputation list | `bool` | `true` | no |
| <a name="input_enable_known_bad_inputs"></a> [enable\_known\_bad\_inputs](#input\_enable\_known\_bad\_inputs) | Enable AWS managed known bad inputs rule | `bool` | `true` | no |
| <a name="input_enable_rate_limiting"></a> [enable\_rate\_limiting](#input\_enable\_rate\_limiting) | Enable rate limiting rule | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Name for the WAF Web ACL | `string` | n/a | yes |
| <a name="input_rate_limit"></a> [rate\_limit](#input\_rate\_limit) | Rate limit per 5 minutes per IP | `number` | `2000` | no |
| <a name="input_resource_arn"></a> [resource\_arn](#input\_resource\_arn) | ARN of the resource to associate with WAF (ALB or API Gateway) | `string` | `null` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | Scope of the WAF (REGIONAL for ALB/API Gateway, CLOUDFRONT for CloudFront) | `string` | `"REGIONAL"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_web_acl_arn"></a> [web\_acl\_arn](#output\_web\_acl\_arn) | ARN of the WAF Web ACL |
| <a name="output_web_acl_capacity"></a> [web\_acl\_capacity](#output\_web\_acl\_capacity) | Capacity units used by the Web ACL |
| <a name="output_web_acl_id"></a> [web\_acl\_id](#output\_web\_acl\_id) | ID of the WAF Web ACL |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
