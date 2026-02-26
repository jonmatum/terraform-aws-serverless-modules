# CRUD API HTTP Architecture

This document provides a detailed architecture view of the CRUD API with HTTP API Gateway and React frontend.

## High-Level Architecture

```mermaid
graph TB
    subgraph "Client"
        Browser[Web Browser]
    end

    subgraph "Frontend - CloudFront + S3"
        CF[CloudFront Distribution]
        S3[S3 Bucket<br/>React App]
    end

    subgraph "Backend - API Gateway HTTP API"
        APIGW[API Gateway HTTP API v2<br/>OpenAPI 3.0]
        VPCLink[VPC Link]
    end

    subgraph "Private Network"
        ALB[Application Load Balancer<br/>Direct Integration]
        ECS[ECS Fargate<br/>FastAPI Backend]
    end

    subgraph "Data Layer"
        DDB[DynamoDB<br/>Items Table]
    end

    Browser -->|Static Assets| CF
    CF --> S3
    Browser -->|API Calls| APIGW
    APIGW --> VPCLink
    VPCLink --> ALB
    ALB --> ECS
    ECS --> DDB
```

## HTTP API vs REST API

```mermaid
graph LR
    subgraph "HTTP API v2 - This Example"
        APIGW2[API Gateway HTTP]
        VPCLink2[VPC Link]
        ALB2[ALB Direct]
    end

    subgraph "REST API v1 - Alternative"
        APIGW1[API Gateway REST]
        VPCLink1[VPC Link]
        NLB1[NLB Required]
        ALB1[ALB]
    end

    APIGW2 --> VPCLink2
    VPCLink2 --> ALB2

    APIGW1 --> VPCLink1
    VPCLink1 --> NLB1
    NLB1 --> ALB1

    style NLB1 fill:#ff6b6b
    style ALB2 fill:#90EE90
```

## CRUD Operations Flow

```mermaid
sequenceDiagram
    participant Client
    participant APIGW as API Gateway HTTP
    participant VPCLink
    participant ALB
    participant ECS as FastAPI
    participant DDB as DynamoDB

    Note over Client,DDB: CREATE Operation
    Client->>APIGW: POST /items
    APIGW->>VPCLink: Forward Request
    VPCLink->>ALB: Direct to ALB
    ALB->>ECS: Route to Task
    ECS->>DDB: PutItem
    DDB->>ECS: Success
    ECS->>Client: 201 Created

    Note over Client,DDB: READ Operation
    Client->>APIGW: GET /items/{id}
    APIGW->>VPCLink: Forward Request
    VPCLink->>ALB: Direct to ALB
    ALB->>ECS: Route to Task
    ECS->>DDB: GetItem
    DDB->>ECS: Item Data
    ECS->>Client: 200 OK + Data
```

## Terraform Resources

```mermaid
graph TB
    subgraph "VPC Module"
        VPC[VPC]
        PrivSub[Private Subnets]
        PubSub[Public Subnets]
        NAT[NAT Gateway]
    end

    subgraph "API Gateway v2 Module"
        APIGW[HTTP API]
        VPCLink[VPC Link]
        Routes[Routes]
        Integration[ALB Integration]
    end

    subgraph "Application Load Balancer"
        ALB[ALB]
        ALBListener[ALB Listener]
        ALBTarget[ALB Target Group]
    end

    subgraph "ECS Module"
        Cluster[ECS Cluster]
        Service[ECS Service]
        TaskDef[Task Definition<br/>FastAPI]
        AutoScale[Auto Scaling]
    end

    subgraph "DynamoDB Module"
        Table[DynamoDB Table]
        Backup[Point-in-Time Recovery]
    end

    subgraph "CloudFront + S3"
        CF[CloudFront Distribution]
        S3Bucket[S3 Bucket]
        OAC[Origin Access Control]
    end

    APIGW --> VPCLink
    VPCLink --> ALB
    ALB --> ALBListener
    ALBListener --> ALBTarget
    ALBTarget --> Service
    Service --> TaskDef
    TaskDef --> Table
    CF --> S3Bucket
```

## Cost Breakdown

| Component | Monthly Cost | Notes |
|-----------|--------------|-------|
| NAT Gateway | ~$32 | Single NAT for dev |
| API Gateway HTTP API | ~$1 | 1M requests (71% cheaper than REST) |
| VPC Link | ~$22 | Per VPC Link |
| Application Load Balancer | ~$20 | No NLB needed |
| Fargate Tasks (2x) | ~$30 | 0.25 vCPU, 0.5 GB each |
| DynamoDB | ~$5 | On-demand, low traffic |
| CloudFront | ~$1 | 1GB transfer |
| S3 Storage | ~$0.50 | React app assets |
| ECR Storage | ~$1 | Container images |
| CloudWatch Logs | ~$5 | 7-day retention |
| **Total** | **~$117/month** | Development configuration |

**Savings vs REST API**: ~$19/month (no NLB required, cheaper API Gateway pricing)

## Related Documentation

- [Main README](./README.md)
- [API Gateway v2 Module](../../modules/api-gateway/)
- [DynamoDB Module](../../modules/dynamodb/)
- [CloudFront + S3 Module](../../modules/cloudfront-s3/)
- [ECS Module](../../modules/ecs/)
