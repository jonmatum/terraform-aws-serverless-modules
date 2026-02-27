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

data "aws_caller_identity" "current" {}

# Standard queue with DLQ
module "orders_queue" {
  source = "../../../modules/sqs"

  queue_name                 = "${var.project_name}-orders"
  visibility_timeout_seconds = 300
  receive_wait_time_seconds  = 20 # Long polling

  create_dlq        = true
  max_receive_count = 3

  tags = var.tags
}

# FIFO queue for sequential processing
module "transactions_queue" {
  source = "../../../modules/sqs"

  queue_name                  = "${var.project_name}-transactions"
  fifo_queue                  = true
  content_based_deduplication = true

  visibility_timeout_seconds = 300
  
  create_dlq = true

  tags = var.tags
}

# Lambda processor
module "ecr" {
  source = "../../../modules/ecr"

  repository_name = "${var.project_name}-processor"
  
  enable_lifecycle_policy = true
  max_image_count        = 5

  tags = var.tags
}

resource "aws_iam_role" "lambda" {
  name = "${var.project_name}-lambda"

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

resource "aws_iam_role_policy" "lambda_sqs" {
  name = "sqs-access"
  role = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = [
          module.orders_queue.queue_arn,
          module.transactions_queue.queue_arn
        ]
      }
    ]
  })
}

module "lambda" {
  source = "../../../modules/lambda"

  function_name      = "${var.project_name}-processor"
  execution_role_arn = aws_iam_role.lambda.arn
  image_uri          = "${module.ecr.repository_url}:latest"
  timeout            = 300
  memory_size        = 512

  environment_variables = {
    ENVIRONMENT = var.environment
  }

  tags = var.tags
}

# SQS event source mappings
resource "aws_lambda_event_source_mapping" "orders" {
  event_source_arn = module.orders_queue.queue_arn
  function_name    = module.lambda.function_name
  batch_size       = 10
  
  scaling_config {
    maximum_concurrency = 10
  }
}

resource "aws_lambda_event_source_mapping" "transactions" {
  event_source_arn = module.transactions_queue.queue_arn
  function_name    = module.lambda.function_name
  batch_size       = 1 # Process one at a time for FIFO
}
