# SQS Queue Architecture

## Overview

Lambda function processing messages from SQS queues with automatic retries and dead letter queue handling.

## High-Level Architecture

```mermaid
graph TB
    subgraph "Message Producers"
        App[Application]
    end

    subgraph "AWS Cloud"
        subgraph "Standard Queue Flow"
            OrdersQ[Orders Queue<br/>Standard]
            OrdersDLQ[Orders DLQ]
        end

        subgraph "FIFO Queue Flow"
            TransQ[Transactions Queue<br/>FIFO]
            TransDLQ[Transactions DLQ]
        end

        subgraph "Processing"
            Lambda[Lambda Processor<br/>Container]
            ECR[ECR Repository]
        end

        subgraph "Monitoring"
            CW[CloudWatch Logs]
        end
    end

    App --> OrdersQ
    App --> TransQ
    OrdersQ -->|Event Source<br/>Batch: 10| Lambda
    TransQ -->|Event Source<br/>Batch: 1| Lambda
    OrdersQ -.->|After 3 retries| OrdersDLQ
    TransQ -.->|After 3 retries| TransDLQ
    Lambda --> CW
    Lambda -.-> ECR
```

## Message Flow

```mermaid
sequenceDiagram
    participant App as Application
    participant SQS as SQS Queue
    participant Lambda as Lambda Function
    participant DLQ as Dead Letter Queue
    participant CW as CloudWatch

    App->>SQS: Send Message
    Note over SQS: Message stored<br/>Visibility timeout: 300s
    
    SQS->>Lambda: Poll (long polling: 20s)
    Lambda->>Lambda: Process Message
    
    alt Success
        Lambda->>SQS: Delete Message
        Lambda->>CW: Log Success
    else Failure (Attempt 1-2)
        Lambda->>SQS: Return to Queue
        Note over SQS: Visibility timeout expires<br/>Message available again
    else Failure (Attempt 3)
        SQS->>DLQ: Move to DLQ
        Lambda->>CW: Log Failure
    end
```

## Components

### SQS Queues

**Orders Queue (Standard)**
- Parallel message processing
- At-least-once delivery
- Best-effort ordering
- Batch size: 10 messages
- Visibility timeout: 300 seconds

**Transactions Queue (FIFO)**
- Sequential message processing
- Exactly-once delivery
- Strict ordering within message group
- Batch size: 1 message
- Content-based deduplication

### Dead Letter Queues

- Captures messages after 3 failed processing attempts
- 14-day message retention
- Same encryption as main queue
- Enables manual inspection and reprocessing

### Lambda Processor

- Container-based function (Python 3.11)
- 512 MB memory
- 300 second timeout
- Event source mapping for both queues
- CloudWatch Logs integration

## Message Flow

### Standard Queue Flow

1. Message sent to Orders Queue
2. Lambda polls queue (long polling: 20s)
3. Lambda receives batch of up to 10 messages
4. Lambda processes messages in parallel
5. On success: Messages deleted from queue
6. On failure: Message returned to queue (visibility timeout)
7. After 3 failures: Message moved to DLQ

### FIFO Queue Flow

1. Message sent to Transactions Queue with message group ID
2. Lambda polls queue
3. Lambda receives 1 message at a time
4. Lambda processes message
5. On success: Message deleted, next message in group processed
6. On failure: Message returned to queue
7. After 3 failures: Message moved to DLQ

## Terraform Resources

```mermaid
graph TB
    subgraph "SQS Module"
        OrdersQ[Orders Queue<br/>Standard]
        OrdersDLQ[Orders DLQ]
        TransQ[Transactions Queue<br/>FIFO]
        TransDLQ[Transactions DLQ]
    end

    subgraph "Lambda Module"
        Lambda[Lambda Function<br/>Container]
        Role[IAM Role]
        ESM1[Event Source Mapping<br/>Orders]
        ESM2[Event Source Mapping<br/>Transactions]
    end

    subgraph "ECR Module"
        ECR[ECR Repository]
        Lifecycle[Lifecycle Policy]
    end

    subgraph "CloudWatch"
        LogGroup[Log Group<br/>7-day retention]
    end

    OrdersQ --> ESM1
    TransQ --> ESM2
    ESM1 --> Lambda
    ESM2 --> Lambda
    Lambda --> Role
    Lambda --> LogGroup
    Lambda -.-> ECR
    OrdersQ -.-> OrdersDLQ
    TransQ -.-> TransDLQ
```

## Retry Strategy

- **Visibility Timeout**: 300 seconds (5 minutes)
- **Max Receive Count**: 3 attempts
- **Backoff**: Automatic via visibility timeout
- **DLQ**: Captures failed messages for investigation

## Monitoring

- Lambda invocation metrics
- SQS queue depth
- DLQ message count
- Processing duration
- Error rates

## Best Practices

1. **Visibility Timeout** should be > Lambda timeout
2. **Long Polling** reduces costs and latency
3. **Batch Size** balances throughput and latency
4. **DLQ Monitoring** alerts on failed messages
5. **Idempotency** handles duplicate messages
