# SNS Fan-out Example

SNS topic with message filtering to multiple SQS queues for event-driven architecture.

## Architecture

See [detailed architecture documentation](architecture.md) for comprehensive diagrams.

## Features

- SNS to SQS fan-out pattern
- Message filtering by attributes
- Multiple queue subscriptions
- Raw message delivery
- Priority-based routing
- Email notifications (optional)

## Quick Start

```bash
cd examples/sns-fanout
./deploy.sh
```

The script handles:
- Infrastructure deployment
- Queue policy configuration
- SNS subscriptions

## Testing

```bash
# Step 1: Get topic ARN
cd terraform
TOPIC_ARN=$(terraform output -raw events_topic_arn)

# Step 2: Publish event (all queues receive)
aws sns publish \
  --topic-arn $TOPIC_ARN \
  --message '{"event_type": "user_signup", "priority": "low"}'

# Step 3: Publish high priority event (all + high priority queues)
aws sns publish \
  --topic-arn $TOPIC_ARN \
  --message '{"event_type": "payment_failed", "priority": "high"}' \
  --message-attributes '{"priority":{"DataType":"String","StringValue":"high"}}'

# Step 4: Publish order event (all + orders queues)
aws sns publish \
  --topic-arn $TOPIC_ARN \
  --message '{"event_type": "order_created", "order_id": "12345"}' \
  --message-attributes '{"event_type":{"DataType":"String","StringValue":"order_created"}}'

# Step 5: Check messages in queues
aws sqs receive-message --queue-url $(terraform output -raw all_events_queue_url)
aws sqs receive-message --queue-url $(terraform output -raw high_priority_queue_url)
aws sqs receive-message --queue-url $(terraform output -raw orders_queue_url)
```

## Configuration

### Message Filtering

**All Events Queue:**
- No filter (receives all messages)

**High Priority Queue:**
```hcl
filter_policy = jsonencode({
  priority = ["high", "urgent"]
})
```

**Orders Queue:**
```hcl
filter_policy = jsonencode({
  event_type = ["order_created", "order_updated"]
})
```

### Email Alerts

Enable email notifications:

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
- Decoupled architectures

## Cost Estimate

**Development** (~$0-2/month):
- SNS: First 1M publishes free
- SQS: First 1M requests free
- CloudWatch Logs: ~$1/month

**Production** (1M events/month, 3 queues):
- SNS publishes: ~$0.50/month
- SQS requests: ~$1.20/month (3 queues)
- CloudWatch Logs: ~$2/month
- **Total: ~$4/month**

## Cleanup

```bash
cd terraform
terraform destroy -auto-approve
```
