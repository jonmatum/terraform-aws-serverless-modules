output "topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.this.arn
}

output "topic_id" {
  description = "ID of the SNS topic"
  value       = aws_sns_topic.this.id
}

output "topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.this.name
}

output "email_subscription_arns" {
  description = "ARNs of email subscriptions"
  value       = aws_sns_topic_subscription.email[*].arn
}

output "sqs_subscription_arns" {
  description = "ARNs of SQS subscriptions"
  value       = aws_sns_topic_subscription.sqs[*].arn
}

output "lambda_subscription_arns" {
  description = "ARNs of Lambda subscriptions"
  value       = aws_sns_topic_subscription.lambda[*].arn
}

output "http_subscription_arns" {
  description = "ARNs of HTTP subscriptions"
  value       = aws_sns_topic_subscription.http[*].arn
}
