# Terraform AWS Lambda Module

Containerized Lambda function module for deploying functions from ECR container images.

## Features

- Container images up to 10GB from ECR
- Lambda Function URLs with CORS support
- VPC integration for private resource access
- AWS X-Ray tracing
- CloudWatch Logs with configurable retention
- Lambda aliases and versioning
- Encryption at rest for logs

## Usage

```hcl
module "lambda" {
  source  = "jonmatum/serverless-modules/aws//modules/lambda"
  version = "~> 2.0"

  function_name      = "my-function"
  execution_role_arn = aws_iam_role.lambda.arn
  image_uri          = "${aws_ecr_repository.lambda.repository_url}:latest"

  timeout     = 30
  memory_size = 512

  environment_variables = {
    ENVIRONMENT = "production"
    LOG_LEVEL   = "info"
  }

  tags = {
    Environment = "production"
  }
}
```

### Lambda with Function URL

```hcl
module "lambda" {
  source  = "jonmatum/serverless-modules/aws//modules/lambda"
  version = "~> 2.0"

  function_name      = "my-api"
  execution_role_arn = aws_iam_role.lambda.arn
  image_uri          = "${aws_ecr_repository.lambda.repository_url}:latest"

  enable_function_url    = true
  function_url_auth_type = "NONE"

  function_url_cors = {
    allow_origins = ["https://example.com"]
    allow_methods = ["GET", "POST"]
    allow_headers = ["content-type"]
    max_age       = 300
  }

  tags = {
    Environment = "production"
  }
}
```

### Lambda in VPC

```hcl
module "lambda" {
  source  = "jonmatum/serverless-modules/aws//modules/lambda"
  version = "~> 2.0"

  function_name      = "my-vpc-function"
  execution_role_arn = aws_iam_role.lambda.arn
  image_uri          = "${aws_ecr_repository.lambda.repository_url}:latest"

  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.lambda.id]

  timeout     = 60
  memory_size = 1024

  tags = {
    Environment = "production"
  }
}
```

## Container Image Requirements

Your Docker image must implement the Lambda Runtime API. Use AWS base images:

```dockerfile
FROM public.ecr.aws/lambda/python:3.11

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY app.py ${LAMBDA_TASK_ROOT}

CMD ["app.handler"]
```

Available base images:
- `public.ecr.aws/lambda/python:3.11`
- `public.ecr.aws/lambda/nodejs:20`
- `public.ecr.aws/lambda/java:17`
- `public.ecr.aws/lambda/dotnet:8`
- `public.ecr.aws/lambda/ruby:3.2`
- `public.ecr.aws/lambda/provided:al2023` (custom runtime)

## IAM Role Requirements

```hcl
resource "aws_iam_role" "lambda" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# For VPC access
resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
```

## Examples

- [lambda-function](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/lambda-function) - Basic containerized Lambda with Function URL

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
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_lambda_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_alias) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_function_event_invoke_config.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_event_invoke_config) | resource |
| [aws_lambda_function_url.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function_url) | resource |
| [aws_lambda_permission.function_url](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alias_description"></a> [alias\_description](#input\_alias\_description) | Description of the Lambda alias | `string` | `"Live alias"` | no |
| <a name="input_alias_function_version"></a> [alias\_function\_version](#input\_alias\_function\_version) | Function version for the alias | `string` | `"$LATEST"` | no |
| <a name="input_alias_name"></a> [alias\_name](#input\_alias\_name) | Name of the Lambda alias | `string` | `"live"` | no |
| <a name="input_create_alias"></a> [create\_alias](#input\_create\_alias) | Create a Lambda alias | `bool` | `false` | no |
| <a name="input_dead_letter_config_target_arn"></a> [dead\_letter\_config\_target\_arn](#input\_dead\_letter\_config\_target\_arn) | ARN of SQS queue or SNS topic for dead letter queue | `string` | `null` | no |
| <a name="input_enable_function_url"></a> [enable\_function\_url](#input\_enable\_function\_url) | Enable Lambda function URL | `bool` | `false` | no |
| <a name="input_enable_lambda_insights"></a> [enable\_lambda\_insights](#input\_enable\_lambda\_insights) | Enable Lambda Insights for enhanced monitoring | `bool` | `false` | no |
| <a name="input_enable_xray"></a> [enable\_xray](#input\_enable\_xray) | Enable AWS X-Ray tracing | `bool` | `false` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables for the Lambda function | `map(string)` | `{}` | no |
| <a name="input_ephemeral_storage_size"></a> [ephemeral\_storage\_size](#input\_ephemeral\_storage\_size) | Size of ephemeral storage in MB (512-10240) | `number` | `null` | no |
| <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn) | ARN of the IAM role for Lambda execution | `string` | n/a | yes |
| <a name="input_function_name"></a> [function\_name](#input\_function\_name) | Name of the Lambda function | `string` | n/a | yes |
| <a name="input_function_url_auth_type"></a> [function\_url\_auth\_type](#input\_function\_url\_auth\_type) | Authorization type for function URL (AWS\_IAM or NONE) | `string` | `"AWS_IAM"` | no |
| <a name="input_function_url_cors"></a> [function\_url\_cors](#input\_function\_url\_cors) | CORS configuration for function URL | `any` | `null` | no |
| <a name="input_image_uri"></a> [image\_uri](#input\_image\_uri) | ECR image URI for the Lambda function | `string` | n/a | yes |
| <a name="input_lambda_insights_extension_version"></a> [lambda\_insights\_extension\_version](#input\_lambda\_insights\_extension\_version) | Lambda Insights extension version | `string` | `"14"` | no |
| <a name="input_log_kms_key_id"></a> [log\_kms\_key\_id](#input\_log\_kms\_key\_id) | KMS key ID for CloudWatch log encryption | `string` | `null` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | CloudWatch log retention in days | `number` | `7` | no |
| <a name="input_maximum_event_age_in_seconds"></a> [maximum\_event\_age\_in\_seconds](#input\_maximum\_event\_age\_in\_seconds) | Maximum age of a request that Lambda sends to a function for processing (60-21600) | `number` | `21600` | no |
| <a name="input_maximum_retry_attempts"></a> [maximum\_retry\_attempts](#input\_maximum\_retry\_attempts) | Maximum retry attempts for async invocations (0-2) | `number` | `2` | no |
| <a name="input_memory_size"></a> [memory\_size](#input\_memory\_size) | Amount of memory in MB | `number` | `512` | no |
| <a name="input_reserved_concurrent_executions"></a> [reserved\_concurrent\_executions](#input\_reserved\_concurrent\_executions) | Reserved concurrent executions (-1 for unreserved) | `number` | `-1` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | Security group IDs for VPC configuration (optional) | `list(string)` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet IDs for VPC configuration (optional) | `list(string)` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | Function timeout in seconds | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alias_arn"></a> [alias\_arn](#output\_alias\_arn) | ARN of the Lambda alias (if created) |
| <a name="output_function_arn"></a> [function\_arn](#output\_function\_arn) | ARN of the Lambda function |
| <a name="output_function_invoke_arn"></a> [function\_invoke\_arn](#output\_function\_invoke\_arn) | Invoke ARN of the Lambda function |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Name of the Lambda function |
| <a name="output_function_url"></a> [function\_url](#output\_function\_url) | URL of the Lambda function (if enabled) |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Name of the CloudWatch log group |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
