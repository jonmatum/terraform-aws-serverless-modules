# CloudWatch Alarms for monitoring

locals {
  alarm_actions = var.alarm_sns_topic_arn != null ? [var.alarm_sns_topic_arn] : (
    var.create_alarm_topic ? [aws_sns_topic.alarms[0].arn] : []
  )
}

# ECS Alarms
module "ecs_alarms" {
  source = "../../../modules/cloudwatch-alarms"

  cluster_name            = var.project_name
  service_name            = module.ecs_mcp.service_name
  alb_arn_suffix          = module.alb.alb_arn_suffix
  target_group_arn_suffix = module.alb.target_group_arn_suffix

  # Optional SNS topic for notifications
  sns_topic_arn = length(local.alarm_actions) > 0 ? local.alarm_actions[0] : null

  tags = var.tags
}

# Lambda MCP Alarms
resource "aws_cloudwatch_metric_alarm" "lambda_mcp_errors" {
  alarm_name          = "${var.project_name}-lambda-mcp-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Lambda MCP function error rate"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = module.lambda_mcp.function_name
  }

  alarm_actions = local.alarm_actions

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "lambda_mcp_throttles" {
  alarm_name          = "${var.project_name}-lambda-mcp-throttles"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Throttles"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Lambda MCP function throttle rate"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = module.lambda_mcp.function_name
  }

  alarm_actions = local.alarm_actions

  tags = var.tags
}

# Lambda Actions Alarms
resource "aws_cloudwatch_metric_alarm" "lambda_actions_errors" {
  alarm_name          = "${var.project_name}-lambda-actions-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "Lambda actions function error rate"
  treat_missing_data  = "notBreaching"

  dimensions = {
    FunctionName = module.lambda_actions.function_name
  }

  alarm_actions = local.alarm_actions

  tags = var.tags
}

# OpenSearch Storage Alarm
resource "aws_cloudwatch_metric_alarm" "opensearch_storage" {
  count = var.enable_knowledge_base ? 1 : 0
  alarm_name          = "${var.project_name}-opensearch-storage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "SearchableDocuments"
  namespace           = "AWS/AOSS"
  period              = 300
  statistic           = "Average"
  threshold           = 1000000
  alarm_description   = "OpenSearch document count high"
  treat_missing_data  = "notBreaching"

  dimensions = {
    CollectionName = aws_opensearchserverless_collection.kb[0].name
  }

  alarm_actions = local.alarm_actions

  tags = var.tags
}

# SNS Topic for alarms (optional)
resource "aws_sns_topic" "alarms" {
  count = var.create_alarm_topic ? 1 : 0
  name  = "${var.project_name}-alarms"

  tags = var.tags
}

resource "aws_sns_topic_subscription" "alarms_email" {
  count     = var.create_alarm_topic && var.alarm_email != null ? 1 : 0
  topic_arn = aws_sns_topic.alarms[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

