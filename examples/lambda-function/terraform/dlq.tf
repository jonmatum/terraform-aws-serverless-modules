# Dead Letter Queue for failed Lambda invocations

resource "aws_sqs_queue" "lambda_dlq" {
  count = var.enable_dlq ? 1 : 0

  name                       = "${var.function_name}-dlq"
  message_retention_seconds  = var.dlq_message_retention_seconds
  visibility_timeout_seconds = 300

  tags = var.tags
}

resource "aws_sqs_queue_policy" "lambda_dlq" {
  count     = var.enable_dlq ? 1 : 0
  queue_url = aws_sqs_queue.lambda_dlq[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action   = "sqs:SendMessage"
      Resource = aws_sqs_queue.lambda_dlq[0].arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = module.lambda.function_arn
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_dlq" {
  count = var.enable_dlq ? 1 : 0
  name  = "${var.function_name}-dlq-policy"
  role  = aws_iam_role.lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "sqs:SendMessage"
      ]
      Resource = aws_sqs_queue.lambda_dlq[0].arn
    }]
  })
}
