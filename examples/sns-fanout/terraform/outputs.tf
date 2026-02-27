output "events_topic_arn" {
  description = "Events topic ARN"
  value       = module.events_topic.topic_arn
}

output "alerts_topic_arn" {
  description = "Alerts topic ARN"
  value       = module.alerts_topic.topic_arn
}

output "all_events_queue_url" {
  description = "All events queue URL"
  value       = module.all_events_queue.queue_url
}

output "high_priority_queue_url" {
  description = "High priority queue URL"
  value       = module.high_priority_queue.queue_url
}

output "orders_queue_url" {
  description = "Orders queue URL"
  value       = module.orders_queue.queue_url
}

output "test_commands" {
  description = "Test commands"
  value = <<-EOT
    # Publish event (all queues receive)
    aws sns publish \
      --topic-arn ${module.events_topic.topic_arn} \
      --message '{"event_type": "user_signup", "priority": "low"}'
    
    # Publish high priority event (all + high priority queues)
    aws sns publish \
      --topic-arn ${module.events_topic.topic_arn} \
      --message '{"event_type": "payment_failed", "priority": "high"}' \
      --message-attributes '{"priority":{"DataType":"String","StringValue":"high"}}'
    
    # Publish order event (all + orders queues)
    aws sns publish \
      --topic-arn ${module.events_topic.topic_arn} \
      --message '{"event_type": "order_created", "order_id": "12345"}' \
      --message-attributes '{"event_type":{"DataType":"String","StringValue":"order_created"}}'
    
    # Check messages in queues
    aws sqs receive-message --queue-url ${module.all_events_queue.queue_url}
    aws sqs receive-message --queue-url ${module.high_priority_queue.queue_url}
    aws sqs receive-message --queue-url ${module.orders_queue.queue_url}
    
    # Send alert email
    aws sns publish \
      --topic-arn ${module.alerts_topic.topic_arn} \
      --subject "Critical Alert" \
      --message "System error detected"
  EOT
}
