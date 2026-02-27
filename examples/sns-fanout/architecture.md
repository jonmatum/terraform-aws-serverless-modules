# SNS Fan-out Architecture

## Overview

SNS topic publishing to multiple SQS queues with message filtering for event-driven architecture.

## High-Level Architecture

```mermaid
graph TB
    subgraph "Event Publishers"
        App[Application]
    end

    subgraph "AWS Cloud"
        subgraph "SNS Topics"
            EventsTopic[Events Topic<br/>Standard]
            AlertsTopic[Alerts Topic<br/>Email]
        end

        subgraph "SQS Queues"
            AllQ[All Events Queue<br/>No Filter]
            HighQ[High Priority Queue<br/>priority filter]
            OrdersQ[Orders Queue<br/>event_type filter]
        end

        subgraph "Dead Letter Queues"
            HighDLQ[High Priority DLQ]
            OrdersDLQ[Orders DLQ]
        end

        subgraph "Subscribers"
            Email[Email Subscribers]
        end
    end

    App --> EventsTopic
    App --> AlertsTopic
    EventsTopic -->|All messages| AllQ
    EventsTopic -->|priority: high/urgent| HighQ
    EventsTopic -->|event_type: order_*| OrdersQ
    AlertsTopic --> Email
    HighQ -.->|After 3 retries| HighDLQ
    OrdersQ -.->|After 3 retries| OrdersDLQ
```

## Message Flow with Filtering

```mermaid
sequenceDiagram
    participant App as Application
    participant SNS as SNS Topic
    participant AllQ as All Events Queue
    participant HighQ as High Priority Queue
    participant OrdersQ as Orders Queue

    App->>SNS: Publish Event<br/>{priority: "high", event_type: "order_created"}
    
    Note over SNS: Evaluate filters
    
    SNS->>AllQ: Deliver (no filter)
    SNS->>HighQ: Deliver (priority matches)
    SNS->>OrdersQ: Deliver (event_type matches)
    
    Note over AllQ,OrdersQ: Independent processing<br/>by consumers
```

## Components

### SNS Topics

**Events Topic**
- Publishes application events
- Multiple SQS subscriptions
- Message filtering enabled
- Standard topic (not FIFO)

**Alerts Topic**
- Critical system alerts
- Email subscriptions
- Display name for email subject

### SQS Queues

**All Events Queue**
- Receives all published events
- No message filtering
- Raw message delivery enabled
- Long polling (20 seconds)

**High Priority Queue**
- Receives only high/urgent priority events
- Filter: `priority = ["high", "urgent"]`
- Separate processing pipeline
- Dead letter queue enabled

**Orders Queue**
- Receives only order-related events
- Filter: `event_type = ["order_created", "order_updated"]`
- Dedicated order processing
- Dead letter queue enabled

## Message Flow

### Standard Event Flow

1. Application publishes event to SNS topic
2. SNS evaluates message attributes against filters
3. SNS delivers to matching queues:
   - All Events Queue (always)
   - High Priority Queue (if priority matches)
   - Orders Queue (if event_type matches)
4. Consumers poll respective queues
5. Messages processed independently

### Filtered Event Flow

**High Priority Event:**
```json
{
  "message": "Payment failed",
  "attributes": {
    "priority": "high"
  }
}
```
→ Delivered to: All Events Queue + High Priority Queue

**Order Event:**
```json
{
  "message": "Order created",
  "attributes": {
    "event_type": "order_created"
  }
}
```
→ Delivered to: All Events Queue + Orders Queue

## Terraform Resources

```mermaid
graph TB
    subgraph "SNS Module"
        EventsTopic[Events Topic]
        AlertsTopic[Alerts Topic]
        Sub1[Subscription: All Events]
        Sub2[Subscription: High Priority]
        Sub3[Subscription: Orders]
        Sub4[Subscription: Email]
    end

    subgraph "SQS Module"
        AllQ[All Events Queue]
        HighQ[High Priority Queue<br/>+ DLQ]
        OrdersQ[Orders Queue<br/>+ DLQ]
    end

    subgraph "IAM"
        Policy1[Queue Policy: All Events]
        Policy2[Queue Policy: High Priority]
        Policy3[Queue Policy: Orders]
    end

    EventsTopic --> Sub1
    EventsTopic --> Sub2
    EventsTopic --> Sub3
    AlertsTopic --> Sub4
    Sub1 --> AllQ
    Sub2 --> HighQ
    Sub3 --> OrdersQ
    AllQ --> Policy1
    HighQ --> Policy2
    OrdersQ --> Policy3
```

## Message Filtering

### Filter Policy Syntax

```json
{
  "attribute_name": ["value1", "value2"]
}
```

### Supported Operators

- **Exact match**: `["value"]`
- **Multiple values**: `["value1", "value2"]`
- **Numeric range**: `[{"numeric": [">=", 0, "<=", 100]}]`
- **Prefix match**: `[{"prefix": "order_"}]`
- **Anything-but**: `[{"anything-but": ["value"]}]`

## Benefits

1. **Decoupling**: Publishers don't know about consumers
2. **Scalability**: Add consumers without changing publishers
3. **Filtering**: Reduce unnecessary processing
4. **Reliability**: Each queue has independent DLQ
5. **Cost Optimization**: Process only relevant messages

## Best Practices

1. **Use message attributes** for filtering (not message body)
2. **Enable raw message delivery** for SQS to avoid JSON wrapping
3. **Monitor DLQs** for failed deliveries
4. **Set appropriate retention** based on processing SLA
5. **Use separate topics** for different event categories
6. **Document filter policies** for consumers

## Monitoring

- SNS publish success/failure
- Number of messages published
- Number of notifications delivered
- SQS queue depth per queue
- DLQ message count
- Message age
