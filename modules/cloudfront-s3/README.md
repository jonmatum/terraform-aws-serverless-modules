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
