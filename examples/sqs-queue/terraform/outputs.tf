output "orders_queue_url" {
  description = "Orders queue URL"
  value       = module.orders_queue.queue_url
}

output "orders_queue_arn" {
  description = "Orders queue ARN"
  value       = module.orders_queue.queue_arn
}

output "orders_dlq_url" {
  description = "Orders DLQ URL"
  value       = module.orders_queue.dlq_id
}

output "transactions_queue_url" {
  description = "Transactions queue URL"
  value       = module.transactions_queue.queue_url
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = module.lambda.function_name
}

output "test_commands" {
  description = "Test commands"
  value = <<-EOT
    # Send message to orders queue
    aws sqs send-message \
      --queue-url ${module.orders_queue.queue_url} \
      --message-body '{"orderId": "12345", "amount": 99.99}'
    
    # Send message to FIFO queue
    aws sqs send-message \
      --queue-url ${module.transactions_queue.queue_url} \
      --message-body '{"transactionId": "tx-001", "amount": 50.00}' \
      --message-group-id "group1"
    
    # Check DLQ for failed messages
    aws sqs receive-message --queue-url ${module.orders_queue.dlq_id}
    
    # View Lambda logs
    aws logs tail /aws/lambda/${module.lambda.function_name} --follow
  EOT
}
