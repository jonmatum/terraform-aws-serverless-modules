# SNS topic for CloudWatch alarm notifications

resource "aws_sns_topic" "lambda_alarms" {
  count = var.create_alarm_topic ? 1 : 0
  name  = "${var.function_name}-alarms"

  tags = var.tags
}

resource "aws_sns_topic_subscription" "lambda_alarms_email" {
  count     = var.create_alarm_topic && var.alarm_email != null ? 1 : 0
  topic_arn = aws_sns_topic.lambda_alarms[0].arn
  protocol  = "email"
  endpoint  = var.alarm_email
}
