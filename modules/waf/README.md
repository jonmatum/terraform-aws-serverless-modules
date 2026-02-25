# Terraform AWS WAF Module

AWS WAF (Web Application Firewall) module for protecting web applications.

## Usage

```hcl
module "waf" {
  source = "github.com/jonmatum/aws-ecs-poc//modules/waf?ref=modules/waf/v0.1.0"

  name  = "my-waf"
  scope = "REGIONAL"

  tags = {
    Environment = "production"
  }
}
```

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
