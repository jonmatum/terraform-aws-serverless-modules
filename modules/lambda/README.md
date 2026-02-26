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
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
