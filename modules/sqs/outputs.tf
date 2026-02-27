output "queue_id" {
  description = "Queue ID (URL)"
  value       = aws_sqs_queue.this.id
}

output "queue_arn" {
  description = "Queue ARN"
  value       = aws_sqs_queue.this.arn
}

output "queue_name" {
  description = "Queue name"
  value       = aws_sqs_queue.this.name
}

output "queue_url" {
  description = "Queue URL"
  value       = aws_sqs_queue.this.url
}

output "dlq_id" {
  description = "DLQ ID (URL)"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].id : null
}

output "dlq_arn" {
  description = "DLQ ARN"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].arn : null
}

output "dlq_name" {
  description = "DLQ name"
  value       = var.create_dlq ? aws_sqs_queue.dlq[0].name : null
}
