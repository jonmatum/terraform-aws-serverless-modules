# SNS Module

Terraform module for creating Amazon SNS topics with subscriptions, encryption, and FIFO support.

## Features

- Standard and FIFO topics
- Multiple subscription types (Email, SQS, Lambda, HTTP/HTTPS)
- Encryption (KMS)
- Message filtering
- Delivery policies
- Data protection policies

## Usage

### Basic Topic

```hcl
module "topic" {
  source = "../../modules/sns"

  topic_name = "my-topic"
  
  tags = {
    Environment = "production"
  }
}
```

### Topic with Email Subscriptions

```hcl
module "alerts" {
  source = "../../modules/sns"

  topic_name   = "alerts"
  display_name = "Production Alerts"
  
  email_subscriptions = [
    "ops@example.com",
    "dev@example.com"
  ]
  
  tags = {
    Environment = "production"
  }
}
```

### Topic with SQS Fan-out

```hcl
module "events" {
  source = "../../modules/sns"

  topic_name = "events"
  
  sqs_subscriptions = [
    {
      queue_arn            = module.queue1.queue_arn
      raw_message_delivery = true
    },
    {
      queue_arn     = module.queue2.queue_arn
      filter_policy = jsonencode({
        event_type = ["order_created"]
      })
    }
  ]
  
  tags = {
    Environment = "production"
  }
}
```

### Topic with Lambda Subscriptions

```hcl
module "notifications" {
  source = "../../modules/sns"

  topic_name = "notifications"
  
  lambda_subscriptions = [
    {
      function_arn = aws_lambda_function.processor.arn
    },
    {
      function_arn  = aws_lambda_function.filtered.arn
      filter_policy = jsonencode({
        priority = ["high"]
      })
    }
  ]
  
  tags = {
    Environment = "production"
  }
}

# Grant SNS permission to invoke Lambda
resource "aws_lambda_permission" "sns" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = module.notifications.topic_arn
}
```

### FIFO Topic

```hcl
module "fifo_topic" {
  source = "../../modules/sns"

  topic_name                  = "my-fifo-topic"
  fifo_topic                  = true
  content_based_deduplication = true
  
  tags = {
    Environment = "production"
  }
}
```

### Encrypted Topic

```hcl
module "encrypted_topic" {
  source = "../../modules/sns"

  topic_name        = "encrypted-topic"
  kms_master_key_id = aws_kms_key.sns.id
  
  tags = {
    Environment = "production"
  }
}
```

### Topic with Custom Policy

```hcl
module "topic" {
  source = "../../modules/sns"

  topic_name = "my-topic"
  
  topic_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "events.amazonaws.com"
      }
      Action   = "SNS:Publish"
      Resource = "*"
    }]
  })
  
  tags = {
    Environment = "production"
  }
}
```

## Message Filtering

```hcl
module "topic" {
  source = "../../modules/sns"

  topic_name = "orders"
  
  sqs_subscriptions = [
    {
      queue_arn     = module.high_priority_queue.queue_arn
      filter_policy = jsonencode({
        priority = ["high", "urgent"]
        region   = ["us-east-1"]
      })
    },
    {
      queue_arn     = module.low_priority_queue.queue_arn
      filter_policy = jsonencode({
        priority = ["low"]
      })
    }
  ]
  
  tags = {
    Environment = "production"
  }
}
```

## Best Practices

1. **Use message filtering** to reduce costs and processing
2. **Enable encryption** for sensitive data
3. **Set display_name** for email subscriptions
4. **Use FIFO topics** with FIFO SQS queues for ordering
5. **Monitor failed deliveries** with CloudWatch
6. **Use raw message delivery** for SQS to avoid JSON wrapping

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| topic_name | Name of the SNS topic | `string` | n/a | yes |
| display_name | Display name for the topic | `string` | `null` | no |
| fifo_topic | Whether this is a FIFO topic | `bool` | `false` | no |
| content_based_deduplication | Enable content-based deduplication | `bool` | `false` | no |
| kms_master_key_id | KMS key ID for encryption | `string` | `null` | no |
| delivery_policy | Delivery policy JSON | `string` | `null` | no |
| topic_policy | IAM policy for the topic | `string` | `null` | no |
| data_protection_policy | Data protection policy JSON | `string` | `null` | no |
| email_subscriptions | List of email addresses | `list(string)` | `[]` | no |
| sqs_subscriptions | List of SQS subscriptions | `list(object)` | `[]` | no |
| lambda_subscriptions | List of Lambda subscriptions | `list(object)` | `[]` | no |
| http_subscriptions | List of HTTP/HTTPS subscriptions | `list(object)` | `[]` | no |
| tags | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| topic_arn | ARN of the SNS topic |
| topic_id | ID of the SNS topic |
| topic_name | Name of the SNS topic |
| email_subscription_arns | ARNs of email subscriptions |
| sqs_subscription_arns | ARNs of SQS subscriptions |
| lambda_subscription_arns | ARNs of Lambda subscriptions |
| http_subscription_arns | ARNs of HTTP subscriptions |
