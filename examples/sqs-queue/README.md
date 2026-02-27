# SQS Queue Example

Lambda function processing messages from SQS queues with dead letter queue support.

## Architecture

See [detailed architecture documentation](architecture.md) for comprehensive diagrams.

## Features

- Standard queue for parallel processing
- FIFO queue for sequential processing
- Dead letter queues for failed messages
- Lambda event source mapping
- Long polling enabled (20 seconds)
- Automatic retries (max 3 attempts)
- CloudWatch Logs integration

## Quick Start

```bash
cd examples/sqs-queue
./deploy.sh
```

The script handles:
- ECR repository creation
- Docker image build and push
- Infrastructure deployment
- Lambda event source mapping

## Testing

```bash
# Step 1: Get queue URLs
cd terraform
ORDERS_QUEUE=$(terraform output -raw orders_queue_url)
TRANSACTIONS_QUEUE=$(terraform output -raw transactions_queue_url)
ORDERS_DLQ=$(terraform output -raw orders_dlq_url)

# Step 2: Send message to standard queue
aws sqs send-message \
  --queue-url $ORDERS_QUEUE \
  --message-body '{"orderId": "12345", "amount": 99.99}'

# Step 3: Send message to FIFO queue
aws sqs send-message \
  --queue-url $TRANSACTIONS_QUEUE \
  --message-body '{"transactionId": "tx-001", "amount": 50.00}' \
  --message-group-id "group1"

# Step 4: View Lambda logs
aws logs tail /aws/lambda/$(terraform output -raw lambda_function_name) --follow

# Step 5: Check DLQ for failed messages
aws sqs receive-message --queue-url $ORDERS_DLQ
```

## Configuration

### Queue Settings

Customize in `terraform/main.tf`:

```hcl
visibility_timeout_seconds = 300  # Match Lambda timeout
receive_wait_time_seconds  = 20   # Long polling
max_receive_count         = 3    # Retries before DLQ
```

### Lambda Settings

```hcl
batch_size              = 10  # Standard queue
batch_size              = 1   # FIFO queue (sequential)
maximum_concurrency     = 10  # Concurrent executions
```

## Message Format

**Orders Queue (Standard):**
```json
{
  "orderId": "12345",
  "amount": 99.99
}
```

**Transactions Queue (FIFO):**
```json
{
  "transactionId": "tx-001",
  "amount": 50.00
}
```

## Cost Estimate

**Development** (~$0-2/month):
- SQS: First 1M requests free
- Lambda: First 1M requests free
- CloudWatch Logs: ~$1/month

**Production** (1M messages/month):
- SQS requests: ~$0.40/month
- Lambda compute: ~$5/month
- CloudWatch Logs: ~$2/month
- **Total: ~$7/month**

## Cleanup

```bash
cd terraform
terraform destroy -auto-approve
```
