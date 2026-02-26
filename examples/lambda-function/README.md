# Lambda Function Example

Containerized Lambda function with Function URL for HTTP access.

## Architecture

See [detailed architecture documentation](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/lambda-function/architecture.md) for comprehensive diagrams.

## Features

- Containerized Lambda function (Python 3.11)
- Lambda Function URL with CORS
- ECR for container images
- CloudWatch Logs with 7-day retention
- IAM execution role with least privilege
- X-Ray tracing support (optional)
- **Production-ready reliability:**
  - CloudWatch alarms (errors, throttles, duration, concurrent executions)
  - Dead Letter Queue (SQS) for failed invocations
  - Configurable retry policies
  - Reserved concurrency limits
  - Lambda Insights for enhanced monitoring

## Quick Start

```bash
cd examples/lambda-function
./deploy.sh
```

The script is idempotent and handles:
- Initial deployment (creates all infrastructure)
- Updates (rebuilds image, updates Lambda function)

Optional: specify image tag
```bash
./deploy.sh v1.2.3
```

## Testing

```bash
# Get function URL
FUNCTION_URL=$(cd terraform && terraform output -raw function_url)

# Test endpoints
curl $FUNCTION_URL
curl $FUNCTION_URL/health
curl $FUNCTION_URL/info
```

Expected responses:

```bash
# Default endpoint
{
  "message": "Hello from containerized Lambda!",
  "method": "GET",
  "path": "/",
  "timestamp": "2024-01-15T10:30:00.123456"
}

# Health check
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00.123456"
}

# Function info
{
  "function_name": "hello-lambda",
  "function_version": "$LATEST",
  "memory_limit": 512,
  "environment": "development",
  "log_level": "info",
  "request_id": "abc123..."
}
```

## Configuration

### Environment Variables

Customize in `terraform/terraform.tfvars`:

```hcl
environment_variables = {
  ENVIRONMENT = "production"
  LOG_LEVEL   = "debug"
  API_KEY     = "your-api-key"
}
```

### Memory and Timeout

```hcl
memory_size = 1024  # MB (128-10240)
timeout     = 60    # seconds (1-900)
```

### CORS Configuration

```hcl
function_url_cors = {
  allow_origins = ["https://example.com"]
  allow_methods = ["GET", "POST", "PUT", "DELETE"]
  allow_headers = ["content-type", "authorization"]
  max_age       = 300
}
```

### Authentication

For private APIs, enable IAM authentication:

```hcl
function_url_auth_type = "AWS_IAM"
```

Then invoke with AWS Signature V4:

```bash
aws lambda invoke-url \
  --function-name hello-lambda \
  --payload '{"key": "value"}' \
  response.json
```

### X-Ray Tracing

Enable distributed tracing:

```hcl
enable_xray = true
```

### Production Reliability

#### Reserved Concurrency

Limit concurrent executions to prevent exhausting account limits:

```hcl
reserved_concurrent_executions = 10
```

#### Dead Letter Queue

Enable DLQ for failed invocations:

```hcl
enable_dlq                    = true
dlq_message_retention_seconds = 1209600 # 14 days
```

#### Retry Configuration

Configure retry behavior for async invocations:

```hcl
maximum_retry_attempts       = 2
maximum_event_age_in_seconds = 21600 # 6 hours
```

#### Lambda Insights

Enable enhanced monitoring with Lambda Insights:

```hcl
enable_lambda_insights = true
```

**Note**: For container-based Lambda functions, you need to add the Lambda Insights extension to your Dockerfile:

```dockerfile
# Copy Lambda Insights extension
COPY --from=public.ecr.aws/awsobservability/aws-otel-lambda:amd64-latest \
    /opt/extensions/otel-extension /opt/extensions/otel-extension

# Set environment variable
ENV AWS_LAMBDA_EXEC_WRAPPER=/opt/otel-extension
```

View metrics in CloudWatch under Lambda Insights dashboard.

#### CloudWatch Alarms

Configure alarms for monitoring:

```hcl
# Option 1: Create SNS topic and email subscription (fully managed)
create_alarm_topic                    = true
alarm_email                           = "your-email@example.com"
alarm_error_threshold                 = 5
alarm_throttle_threshold              = 5
alarm_duration_threshold              = 25000 # milliseconds
alarm_concurrent_executions_threshold = 8

# Option 2: Use existing SNS topic
alarm_sns_topic_arn = "arn:aws:sns:us-east-1:123456789012:lambda-alerts"
```

**Note**: When using `create_alarm_topic = true`, you'll receive an email confirmation to subscribe to the SNS topic.

## Local Development

```bash
cd app

# Test locally with Docker
docker build -t lambda-test .
docker run -p 9000:8080 lambda-test

# Invoke locally
curl -XPOST "http://localhost:9000/2015-03-31/functions/function/invocations" \
  -d '{"rawPath": "/health"}'
```

## Container Image

The example uses AWS Lambda Python 3.11 base image. You can use other runtimes:

- `public.ecr.aws/lambda/nodejs:20`
- `public.ecr.aws/lambda/java:17`
- `public.ecr.aws/lambda/dotnet:8`
- `public.ecr.aws/lambda/ruby:3.2`
- `public.ecr.aws/lambda/provided:al2023` (custom runtime)

## Cost Estimate

**Development** (~$0-5/month):
- Lambda: First 1M requests free, then $0.20 per 1M
- Lambda compute: First 400,000 GB-seconds free
- ECR storage: $0.10 per GB/month
- CloudWatch Logs: $0.50 per GB ingested

**Production** (100K requests/day, 512MB, 1s avg):
- Lambda requests: ~$6/month
- Lambda compute: ~$10/month
- ECR storage: ~$1/month
- CloudWatch Logs: ~$2/month
- **Total: ~$19/month**

## Cleanup

```bash
cd terraform
terraform destroy -auto-approve
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
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ../../../modules/ecr | n/a |
| <a name="module_lambda"></a> [lambda](#module\_lambda) | ../../../modules/lambda | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.lambda_basic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.lambda_xray](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_enable_function_url"></a> [enable\_function\_url](#input\_enable\_function\_url) | Enable Lambda function URL | `bool` | `true` | no |
| <a name="input_enable_xray"></a> [enable\_xray](#input\_enable\_xray) | Enable AWS X-Ray tracing | `bool` | `false` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables for the Lambda function | `map(string)` | <pre>{<br/>  "ENVIRONMENT": "development",<br/>  "LOG_LEVEL": "info"<br/>}</pre> | no |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name of the Lambda function | `string` | `"hello-lambda"` | no |
| <a name="input_function_url_auth_type"></a> [function\_url\_auth\_type](#input\_function\_url\_auth\_type) | Authorization type for function URL (AWS\_IAM or NONE) | `string` | `"NONE"` | no |
| <a name="input_function_url_cors"></a> [function\_url\_cors](#input\_function\_url\_cors) | CORS configuration for function URL | `map(any)` | <pre>{<br/>  "allow_headers": [<br/>    "content-type"<br/>  ],<br/>  "allow_methods": [<br/>    "GET",<br/>    "POST"<br/>  ],<br/>  "allow_origins": [<br/>    "*"<br/>  ],<br/>  "max_age": 300<br/>}</pre> | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Docker image tag | `string` | `"latest"` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | CloudWatch log retention in days | `number` | `7` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Amount of memory in MB | `number` | `512` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | <pre>{<br/>  "Environment": "development",<br/>  "ManagedBy": "terraform",<br/>  "Project": "lambda-function"<br/>}</pre> | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Function timeout in seconds | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_repository_url"></a> [ecr\_repository\_url](#output\_ecr\_repository\_url) | URL of the ECR repository |
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | ARN of the Lambda function |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Name of the Lambda function |
| <a name="output_function_url"></a> [function\_url](#output\_function\_url) | URL of the Lambda function |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Name of the CloudWatch log group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
