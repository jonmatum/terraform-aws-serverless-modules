resource "aws_sns_topic" "this" {
  name              = var.fifo_topic ? "${var.topic_name}.fifo" : var.topic_name
  fifo_topic        = var.fifo_topic
  content_based_deduplication = var.fifo_topic ? var.content_based_deduplication : null
  
  display_name = var.display_name

  # Encryption
  kms_master_key_id = var.kms_master_key_id

  # Delivery policy
  delivery_policy = var.delivery_policy

  tags = var.tags
}

# Topic policy
resource "aws_sns_topic_policy" "this" {
  count = var.topic_policy != null ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = var.topic_policy
}

# Email subscriptions
resource "aws_sns_topic_subscription" "email" {
  count = length(var.email_subscriptions)

  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.email_subscriptions[count.index]
}

# SQS subscriptions
resource "aws_sns_topic_subscription" "sqs" {
  count = length(var.sqs_subscriptions)

  topic_arn = aws_sns_topic.this.arn
  protocol  = "sqs"
  endpoint  = var.sqs_subscriptions[count.index].queue_arn

  raw_message_delivery = lookup(var.sqs_subscriptions[count.index], "raw_message_delivery", false)
  filter_policy        = lookup(var.sqs_subscriptions[count.index], "filter_policy", null)
}

# Lambda subscriptions
resource "aws_sns_topic_subscription" "lambda" {
  count = length(var.lambda_subscriptions)

  topic_arn = aws_sns_topic.this.arn
  protocol  = "lambda"
  endpoint  = var.lambda_subscriptions[count.index].function_arn

  filter_policy = lookup(var.lambda_subscriptions[count.index], "filter_policy", null)
}

# HTTP/HTTPS subscriptions
resource "aws_sns_topic_subscription" "http" {
  count = length(var.http_subscriptions)

  topic_arn = aws_sns_topic.this.arn
  protocol  = var.http_subscriptions[count.index].protocol
  endpoint  = var.http_subscriptions[count.index].endpoint

  filter_policy = lookup(var.http_subscriptions[count.index], "filter_policy", null)
}

# Data protection policy
resource "aws_sns_topic_data_protection_policy" "this" {
  count = var.data_protection_policy != null ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = var.data_protection_policy
}
