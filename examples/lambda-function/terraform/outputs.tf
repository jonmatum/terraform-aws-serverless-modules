output "function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda.function_name
}

output "function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda.function_arn
}

output "function_url" {
  description = "URL of the Lambda function"
  value       = module.lambda.function_url
}

output "ecr_repository_url" {
  description = "URL of the ECR repository"
  value       = module.ecr.repository_url
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = module.lambda.log_group_name
}

output "dlq_url" {
  description = "URL of the Dead Letter Queue"
  value       = var.enable_dlq ? aws_sqs_queue.lambda_dlq[0].url : null
}

output "dlq_arn" {
  description = "ARN of the Dead Letter Queue"
  value       = var.enable_dlq ? aws_sqs_queue.lambda_dlq[0].arn : null
}

output "alarm_arns" {
  description = "ARNs of CloudWatch alarms"
  value = {
    errors                = aws_cloudwatch_metric_alarm.lambda_errors.arn
    throttles             = aws_cloudwatch_metric_alarm.lambda_throttles.arn
    duration              = aws_cloudwatch_metric_alarm.lambda_duration.arn
    concurrent_executions = aws_cloudwatch_metric_alarm.lambda_concurrent_executions.arn
  }
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  value       = var.create_alarm_topic ? aws_sns_topic.lambda_alarms[0].arn : null
}
