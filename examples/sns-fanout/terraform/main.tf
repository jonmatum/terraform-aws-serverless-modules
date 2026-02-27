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

# SNS topic for events
module "events_topic" {
  source = "../../../modules/sns"

  topic_name   = "${var.project_name}-events"
  display_name = "Application Events"

  sqs_subscriptions = [
    {
      queue_arn            = module.all_events_queue.queue_arn
      raw_message_delivery = true
    },
    {
      queue_arn     = module.high_priority_queue.queue_arn
      filter_policy = jsonencode({
        priority = ["high", "urgent"]
      })
    },
    {
      queue_arn     = module.orders_queue.queue_arn
      filter_policy = jsonencode({
        event_type = ["order_created", "order_updated"]
      })
    }
  ]

  tags = var.tags
}

# Queue for all events
module "all_events_queue" {
  source = "../../../modules/sqs"

  queue_name                = "${var.project_name}-all-events"
  receive_wait_time_seconds = 20

  create_dlq = true

  tags = var.tags
}

# Queue for high priority events
module "high_priority_queue" {
  source = "../../../modules/sqs"

  queue_name                = "${var.project_name}-high-priority"
  receive_wait_time_seconds = 20

  create_dlq = true

  tags = var.tags
}

# Queue for order events
module "orders_queue" {
  source = "../../../modules/sqs"

  queue_name                = "${var.project_name}-orders"
  receive_wait_time_seconds = 20

  create_dlq = true

  tags = var.tags
}

# SQS queue policies to allow SNS
resource "aws_sqs_queue_policy" "all_events" {
  queue_url = module.all_events_queue.queue_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "sns.amazonaws.com"
      }
      Action   = "sqs:SendMessage"
      Resource = module.all_events_queue.queue_arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = module.events_topic.topic_arn
        }
      }
    }]
  })
}

resource "aws_sqs_queue_policy" "high_priority" {
  queue_url = module.high_priority_queue.queue_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "sns.amazonaws.com"
      }
      Action   = "sqs:SendMessage"
      Resource = module.high_priority_queue.queue_arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = module.events_topic.topic_arn
        }
      }
    }]
  })
}

resource "aws_sqs_queue_policy" "orders" {
  queue_url = module.orders_queue.queue_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "sns.amazonaws.com"
      }
      Action   = "sqs:SendMessage"
      Resource = module.orders_queue.queue_arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = module.events_topic.topic_arn
        }
      }
    }]
  })
}

# Optional: Email notifications
module "alerts_topic" {
  source = "../../../modules/sns"

  topic_name   = "${var.project_name}-alerts"
  display_name = "Critical Alerts"

  email_subscriptions = var.alert_emails

  tags = var.tags
}
