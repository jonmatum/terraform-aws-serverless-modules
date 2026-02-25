# Terraform AWS CloudFront S3 Module

CloudFront distribution with S3 origin for static website hosting.

## Usage

```hcl
module "cloudfront_s3" {
  source = "github.com/jonmatum/aws-ecs-poc//modules/cloudfront-s3?ref=modules/cloudfront-s3/v0.1.0"

  bucket_name = "my-static-website"
  domain_name = "example.com"

  tags = {
    Environment = "production"
  }
}
```

## Features

- S3 bucket for static content
- CloudFront distribution with OAI
- HTTPS support
- Custom domain support
- Cache optimization

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| bucket_name | Name of the S3 bucket | string | - | yes |
| domain_name | Custom domain name | string | null | no |
| tags | Tags to apply to resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_id | ID of the S3 bucket |
| cloudfront_distribution_id | ID of the CloudFront distribution |
| cloudfront_domain_name | Domain name of the CloudFront distribution |
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.33.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_function.spa_routing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_function) | resource |
| [aws_cloudfront_origin_access_control.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_control) | resource |
| [aws_s3_bucket.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_lifecycle_configuration.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_ownership_controls.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.website](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ACM certificate ARN for custom domain (must be in us-east-1) | `string` | `null` | no |
| <a name="input_default_root_object"></a> [default\_root\_object](#input\_default\_root\_object) | Default root object | `string` | `"index.html"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Custom domain name (optional) | `string` | `null` | no |
| <a name="input_enable_ipv6"></a> [enable\_ipv6](#input\_enable\_ipv6) | Enable IPv6 | `bool` | `true` | no |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Enable CloudFront access logs | `bool` | `true` | no |
| <a name="input_geo_restriction_locations"></a> [geo\_restriction\_locations](#input\_geo\_restriction\_locations) | List of country codes for geo restriction | `list(string)` | `[]` | no |
| <a name="input_geo_restriction_type"></a> [geo\_restriction\_type](#input\_geo\_restriction\_type) | Geo restriction type (none, whitelist, blacklist) | `string` | `"none"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for resources | `string` | n/a | yes |
| <a name="input_price_class"></a> [price\_class](#input\_price\_class) | CloudFront price class | `string` | `"PriceClass_100"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | ARN of the S3 bucket |
| <a name="output_bucket_name"></a> [bucket\_name](#output\_bucket\_name) | Name of the S3 bucket |
| <a name="output_cloudfront_distribution_arn"></a> [cloudfront\_distribution\_arn](#output\_cloudfront\_distribution\_arn) | ARN of the CloudFront distribution |
| <a name="output_cloudfront_distribution_id"></a> [cloudfront\_distribution\_id](#output\_cloudfront\_distribution\_id) | ID of the CloudFront distribution |
| <a name="output_cloudfront_domain_name"></a> [cloudfront\_domain\_name](#output\_cloudfront\_domain\_name) | Domain name of the CloudFront distribution |
| <a name="output_website_url"></a> [website\_url](#output\_website\_url) | URL of the website |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
