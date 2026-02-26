terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "ecr" {
  source = "../../../modules/ecr"

  repository_name      = var.function_name
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true

  tags = var.tags
}

module "lambda" {
  source = "../../../modules/lambda"

  function_name      = var.function_name
  execution_role_arn = aws_iam_role.lambda.arn
  image_uri          = "${module.ecr.repository_url}:${var.image_tag}"

  timeout     = var.timeout
  memory_size = var.memory_size

  environment_variables = var.environment_variables

  enable_function_url    = var.enable_function_url
  function_url_auth_type = var.function_url_auth_type
  function_url_cors      = var.function_url_cors

  enable_xray        = var.enable_xray
  log_retention_days = var.log_retention_days

  # Production reliability features
  reserved_concurrent_executions = var.reserved_concurrent_executions
  dead_letter_config_target_arn  = var.enable_dlq ? aws_sqs_queue.lambda_dlq[0].arn : null
  maximum_retry_attempts         = var.maximum_retry_attempts
  maximum_event_age_in_seconds   = var.maximum_event_age_in_seconds
  enable_lambda_insights         = var.enable_lambda_insights

  tags = var.tags
}

resource "aws_iam_role" "lambda" {
  name = "${var.function_name}-execution-role"

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

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_xray" {
  count      = var.enable_xray ? 1 : 0
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_insights" {
  count      = var.enable_lambda_insights ? 1 : 0
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLambdaInsightsExecutionRolePolicy"
}
