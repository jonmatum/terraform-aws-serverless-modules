# SQS Module

Terraform module for creating Amazon SQS queues with dead letter queues, encryption, and FIFO support.

## Features

- Standard and FIFO queues
- Dead letter queue (DLQ) support
- Encryption (SQS-managed or KMS)
- Long polling
- Message retention configuration
- Queue policies
- Redrive policies

## Usage

### Basic Queue

```hcl
module "queue" {
  source = "../../modules/sqs"

  queue_name = "my-queue"
  
  tags = {
    Environment = "production"
  }
}
```

### Queue with DLQ

```hcl
module "queue" {
  source = "../../modules/sqs"

  queue_name = "my-queue"
  
  create_dlq        = true
  max_receive_count = 3
  
  tags = {
    Environment = "production"
  }
}
```

### FIFO Queue

```hcl
module "fifo_queue" {
  source = "../../modules/sqs"

  queue_name                  = "my-fifo-queue"
  fifo_queue                  = true
  content_based_deduplication = true
  
  create_dlq = true
  
  tags = {
    Environment = "production"
  }
}
```

### Queue with KMS Encryption

```hcl
module "encrypted_queue" {
  source = "../../modules/sqs"

  queue_name        = "my-encrypted-queue"
  kms_master_key_id = aws_kms_key.sqs.id
  
  tags = {
    Environment = "production"
  }
}
```

### Queue with Custom Policy

```hcl
module "queue" {
  source = "../../modules/sqs"

  queue_name = "my-queue"
  
  queue_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action   = "sqs:SendMessage"
      Resource = "*"
    }]
  })
  
  tags = {
    Environment = "production"
  }
}
```

## Lambda Integration

```hcl
module "queue" {
  source = "../../modules/sqs"

  queue_name                 = "lambda-queue"
  visibility_timeout_seconds = 300  # Match Lambda timeout
  
  create_dlq = true
  
  tags = {
    Environment = "production"
  }
}

resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = module.queue.queue_arn
  function_name    = aws_lambda_function.processor.arn
  batch_size       = 10
}
```

## Best Practices

1. **Always use DLQ** for production queues
2. **Set visibility timeout** > Lambda function timeout
3. **Enable encryption** for sensitive data
4. **Use FIFO queues** when order matters
5. **Configure long polling** (receive_wait_time_seconds > 0) to reduce costs
6. **Monitor DLQ** for failed messages

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| queue_name | Name of the SQS queue | `string` | n/a | yes |
| fifo_queue | Whether this is a FIFO queue | `bool` | `false` | no |
| content_based_deduplication | Enable content-based deduplication for FIFO queues | `bool` | `false` | no |
| visibility_timeout_seconds | Visibility timeout for the queue | `number` | `30` | no |
| message_retention_seconds | Number of seconds to retain messages | `number` | `345600` | no |
| max_message_size | Maximum message size in bytes | `number` | `262144` | no |
| delay_seconds | Delay before message is available | `number` | `0` | no |
| receive_wait_time_seconds | Long polling wait time | `number` | `0` | no |
| create_dlq | Create a dead letter queue | `bool` | `false` | no |
| dlq_arn | ARN of existing DLQ | `string` | `null` | no |
| max_receive_count | Max receives before sending to DLQ | `number` | `3` | no |
| dlq_message_retention_seconds | Message retention for DLQ | `number` | `1209600` | no |
| kms_master_key_id | KMS key ID for encryption | `string` | `null` | no |
| queue_policy | IAM policy for the queue | `string` | `null` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| queue_id | Queue ID (URL) |
| queue_arn | Queue ARN |
| queue_name | Queue name |
| queue_url | Queue URL |
| dlq_id | DLQ ID (URL) |
| dlq_arn | DLQ ARN |
| dlq_name | DLQ name |
