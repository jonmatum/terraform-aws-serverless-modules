# SNS Fan-out Example

SNS topic with message filtering to multiple SQS queues.

## Architecture

```
                    SNS Topic
                        |
        +---------------+---------------+
        |               |               |
   All Events    High Priority      Orders
     Queue          Queue            Queue
   (no filter)   (priority filter) (event_type filter)
```

## Features

- SNS to SQS fan-out pattern
- Message filtering by attributes
- Multiple queue subscriptions
- Email notifications (optional)
- Raw message delivery

## Quick Start

```bash
cd examples/sns-fanout
./deploy.sh
```

## Testing

```bash
cd terraform

# Publish event to all queues
aws sns publish \
  --topic-arn $(terraform output -raw events_topic_arn) \
  --message '{"event_type": "user_signup", "priority": "low"}'

# Publish high priority event
aws sns publish \
  --topic-arn $(terraform output -raw events_topic_arn) \
  --message '{"event_type": "payment_failed", "priority": "high"}' \
  --message-attributes '{"priority":{"DataType":"String","StringValue":"high"}}'

# Publish order event
aws sns publish \
  --topic-arn $(terraform output -raw events_topic_arn) \
  --message '{"event_type": "order_created", "order_id": "12345"}' \
  --message-attributes '{"event_type":{"DataType":"String","StringValue":"order_created"}}'

# Check messages
aws sqs receive-message --queue-url $(terraform output -raw all_events_queue_url)
aws sqs receive-message --queue-url $(terraform output -raw high_priority_queue_url)
aws sqs receive-message --queue-url $(terraform output -raw orders_queue_url)
```

## Message Filtering

**All Events Queue:**
- Receives all messages (no filter)

**High Priority Queue:**
```json
{
  "priority": ["high", "urgent"]
}
```

**Orders Queue:**
```json
{
  "event_type": ["order_created", "order_updated"]
}
```

## Email Alerts

To enable email notifications:

```bash
terraform apply -var='alert_emails=["your-email@example.com"]'
```

You'll receive a confirmation email to subscribe.

## Use Cases

- Event-driven microservices
- Multi-consumer message processing
- Priority-based routing
- Audit logging
- Real-time notifications

## Cleanup

```bash
cd terraform
terraform destroy -auto-approve
```
