# SQS Queue Example

Lambda function processing messages from SQS queues with dead letter queue support.

## Architecture

```
SQS Queue (Standard) → Lambda Processor
     ↓ (failed)
   DLQ Queue

SQS Queue (FIFO) → Lambda Processor
     ↓ (failed)
   DLQ Queue
```

## Features

- Standard queue for parallel processing
- FIFO queue for sequential processing
- Dead letter queues for failed messages
- Lambda event source mapping
- Long polling enabled
- Automatic retries

## Quick Start

```bash
cd examples/sqs-queue
./deploy.sh
```

## Testing

```bash
cd terraform

# Send message to standard queue
aws sqs send-message \
  --queue-url $(terraform output -raw orders_queue_url) \
  --message-body '{"orderId": "12345", "amount": 99.99}'

# Send message to FIFO queue
aws sqs send-message \
  --queue-url $(terraform output -raw transactions_queue_url) \
  --message-body '{"transactionId": "tx-001", "amount": 50.00}' \
  --message-group-id "group1"

# Check Lambda logs
aws logs tail /aws/lambda/$(terraform output -raw lambda_function_name) --follow

# Check DLQ for failed messages
aws sqs receive-message --queue-url $(terraform output -raw orders_dlq_url)
```

## Configuration

### Queue Settings

```hcl
visibility_timeout_seconds = 300  # Match Lambda timeout
receive_wait_time_seconds  = 20   # Long polling
max_receive_count         = 3    # Retries before DLQ
```

### Lambda Settings

```hcl
batch_size              = 10  # Standard queue
batch_size              = 1   # FIFO queue
maximum_concurrency     = 10  # Concurrent executions
```

## Message Format

**Orders Queue:**
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

## Cleanup

```bash
cd terraform
terraform destroy -auto-approve
```
