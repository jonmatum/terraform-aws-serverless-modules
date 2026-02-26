# AWS Serverless Architecture

This document provides an interactive view of the complete AWS serverless architecture supported by this module collection.

## Architecture Diagram

```mermaid
graph TB
    subgraph "Public Subnet"
        ALB[Application Load Balancer]
        NAT[NAT Gateway]
        APIGW[API Gateway]
        AGENTGW[Agent Gateway]
    end

    subgraph "Private Subnet"
        ECS[ECS Fargate Tasks]
        LAMBDA[Lambda Functions]
        AGENTRT[Agent Runtime]
    end

    subgraph "Data Layer"
        DDB[DynamoDB]
        RDS[RDS Database]
        ECR[ECR Repository]
    end

    subgraph "Messaging & Queues"
        SQS[SQS Queue]
        SNS[SNS Topic]
    end

    subgraph "Orchestration"
        SF[Step Functions]
    end

    subgraph "AI/ML Services"
        BEDROCK[Amazon Bedrock]
        AGENTCORE[Bedrock AgentCore]
    end

    subgraph "Security & Monitoring"
        WAF[AWS WAF]
        CW[CloudWatch]
        SM[Secrets Manager]
    end

    Internet((Internet)) --> WAF
    WAF --> ALB
    WAF --> APIGW
    WAF --> AGENTGW
    ALB --> ECS
    APIGW --> ECS
    APIGW --> LAMBDA
    AGENTGW --> AGENTRT
    AGENTRT --> BEDROCK
    AGENTRT --> AGENTCORE
    AGENTCORE --> LAMBDA
    AGENTCORE --> SF
    ECS --> DDB
    ECS --> RDS
    LAMBDA --> DDB
    LAMBDA --> RDS
    ECS --> SQS
    LAMBDA --> SQS
    SQS --> SNS
    SF --> LAMBDA
    SF --> ECS
    ECS --> NAT
    NAT --> Internet
    ECS -.-> ECR
    ECS -.-> SM
    LAMBDA -.-> SM
    AGENTRT -.-> SM
    ECS -.-> CW
    LAMBDA -.-> CW
    SF -.-> CW
    AGENTRT -.-> CW

    style ALB fill:#FF9900
    style ECS fill:#FF9900
    style DDB fill:#FF9900
    style APIGW fill:#FF9900
    style LAMBDA fill:#FF9900
    style SF fill:#FF9900
    style AGENTGW fill:#FF9900
    style AGENTRT fill:#FF9900
    style BEDROCK fill:#FF9900
```

## Component Status

### Currently Available Modules
- VPC - Multi-AZ networking with NAT gateways
- ECS - Fargate container orchestration
- ALB - Application Load Balancer
- API Gateway - HTTP API (v2) and REST API (v1)
- DynamoDB - NoSQL database
- ECR - Container registry
- WAF - Web Application Firewall
- CloudWatch - Monitoring and alarms
- CloudFront + S3 - CDN and static hosting

### Planned Modules
- Lambda - Serverless functions
- RDS - Relational database
- SQS - Message queuing
- SNS - Pub/sub messaging
- Step Functions - Workflow orchestration
- Agent Gateway - AI agent API gateway
- Agent Runtime - AI agent execution environment
- Bedrock Integration - Foundation model access
- AgentCore - Bedrock agent orchestration

## Architecture Patterns

### Container-Based Pattern (Available Now)

```mermaid
graph LR
    Internet[Internet] --> WAF[WAF]
    WAF --> ALB[ALB]
    ALB --> ECS[ECS Fargate]
    ECS --> DDB[DynamoDB]
    ECS --> RDS[RDS - Planned]
```

### API Gateway Pattern (Available Now)

```mermaid
graph LR
    Internet[Internet] --> WAF[WAF]
    WAF --> APIGW[API Gateway]
    APIGW --> ECS[ECS Fargate]
    ECS --> DDB[DynamoDB]
```

### Agent Runtime Pattern (Available Now)

```mermaid
graph LR
    Internet[Internet] --> AGENTGW[Agent Gateway]
    AGENTGW --> AGENTRT[Agent Runtime ECS]
    AGENTRT --> MCP[MCP Protocol]
```

### Serverless Pattern (Planned)

```mermaid
graph LR
    Internet[Internet] --> APIGW[API Gateway]
    APIGW --> LAMBDA[Lambda]
    LAMBDA --> DDB[DynamoDB]
    LAMBDA --> SQS[SQS]
    SQS --> SNS[SNS]
```

### AI/ML Pattern (Planned)

```mermaid
graph LR
    Internet[Internet] --> AGENTGW[Agent Gateway]
    AGENTGW --> AGENTRT[Agent Runtime]
    AGENTRT --> BEDROCK[Bedrock]
    AGENTRT --> AGENTCORE[AgentCore]
    AGENTCORE --> LAMBDA[Lambda]
    AGENTCORE --> SF[Step Functions]
```

## Related Documentation

- [Well-Architected Framework](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/docs/well-architected.md)
- [Module Documentation](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules)
- [Example Implementations](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples)
