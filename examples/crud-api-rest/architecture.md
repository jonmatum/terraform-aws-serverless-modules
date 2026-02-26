# CRUD API REST Architecture

This document provides a detailed architecture view of the CRUD API with REST API Gateway and React frontend.

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

    subgraph "Backend - API Gateway REST API"
        APIGW[API Gateway REST API v1<br/>Swagger/OpenAPI]
        VPCLink[VPC Link]
    end

    subgraph "Private Network"
        NLB[Network Load Balancer<br/>Required for REST API]
        ALB[Application Load Balancer]
        ECS[ECS Fargate<br/>FastAPI Backend]
    end

    subgraph "Data Layer"
        DDB[DynamoDB<br/>Items Table]
    end

    Browser -->|Static Assets| CF
    CF --> S3
    Browser -->|API Calls| APIGW
    APIGW --> VPCLink
    VPCLink --> NLB
    NLB --> ALB
    ALB --> ECS
    ECS --> DDB
```

## CRUD Operations Flow

```mermaid
sequenceDiagram
    participant Client
    participant APIGW as API Gateway
    participant VPCLink
    participant NLB
    participant ALB
    participant ECS as FastAPI
    participant DDB as DynamoDB

    Note over Client,DDB: CREATE Operation
    Client->>APIGW: POST /items
    APIGW->>VPCLink: Forward Request
    VPCLink->>NLB: Private Connection
    NLB->>ALB: Load Balance
    ALB->>ECS: Route to Task
    ECS->>DDB: PutItem
    DDB->>ECS: Success
    ECS->>Client: 201 Created

    Note over Client,DDB: READ Operation
    Client->>APIGW: GET /items/{id}
    APIGW->>VPCLink: Forward Request
    VPCLink->>NLB: Private Connection
    NLB->>ALB: Load Balance
    ALB->>ECS: Route to Task
    ECS->>DDB: GetItem
    DDB->>ECS: Item Data
    ECS->>Client: 200 OK + Data

    Note over Client,DDB: UPDATE Operation
    Client->>APIGW: PUT /items/{id}
    APIGW->>VPCLink: Forward Request
    VPCLink->>NLB: Private Connection
    NLB->>ALB: Load Balance
    ALB->>ECS: Route to Task
    ECS->>DDB: UpdateItem
    DDB->>ECS: Success
    ECS->>Client: 200 OK

    Note over Client,DDB: DELETE Operation
    Client->>APIGW: DELETE /items/{id}
    APIGW->>VPCLink: Forward Request
    VPCLink->>NLB: Private Connection
    NLB->>ALB: Load Balance
    ALB->>ECS: Route to Task
    ECS->>DDB: DeleteItem
    DDB->>ECS: Success
    ECS->>Client: 204 No Content
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

    subgraph "API Gateway v1 Module"
        APIGW[REST API]
        Swagger[Swagger Spec]
        VPCLink[VPC Link]
        Deployment[API Deployment]
        Stage[API Stage]
    end

    subgraph "Network Load Balancer"
        NLB[NLB<br/>Required for REST API]
        NLBListener[NLB Listener]
        NLBTarget[NLB Target Group]
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
        GSI[Global Secondary Index]
        Backup[Point-in-Time Recovery]
    end

    subgraph "CloudFront + S3"
        CF[CloudFront Distribution]
        S3Bucket[S3 Bucket]
        OAC[Origin Access Control]
    end

    APIGW --> Swagger
    APIGW --> VPCLink
    VPCLink --> NLB
    NLB --> NLBListener
    NLBListener --> NLBTarget
    NLBTarget --> ALB
    ALB --> ALBListener
    ALBListener --> ALBTarget
    ALBTarget --> Service
    Service --> TaskDef
    Service --> AutoScale
    TaskDef --> Table
    CF --> S3Bucket
    CF --> OAC
```

## Deployment Flow

```mermaid
graph TB
    Start[Run deploy.sh] --> BuildBackend[Build FastAPI Image]
    BuildBackend --> PushECR[Push to ECR]
    PushECR --> TFApply[Terraform Apply]

    TFApply --> CreateVPC[Create VPC]
    CreateVPC --> CreateDDB[Create DynamoDB]
    CreateDDB --> CreateECS[Create ECS Service]
    CreateECS --> CreateALB[Create ALB]
    CreateALB --> CreateNLB[Create NLB]
    CreateNLB --> CreateVPCLink[Create VPC Link]
    CreateVPCLink --> CreateAPIGW[Create API Gateway]
    CreateAPIGW --> HealthCheck[Health Check Backend]

    HealthCheck --> BuildFrontend[Build React App]
    BuildFrontend --> CreateS3[Create S3 Bucket]
    CreateS3 --> UploadAssets[Upload React Assets]
    UploadAssets --> CreateCF[Create CloudFront]
    CreateCF --> Ready[Deployment Complete]
```

## Cost Breakdown

| Component | Monthly Cost | Notes |
|-----------|--------------|-------|
| NAT Gateway | ~$32 | Single NAT for dev |
| API Gateway REST API | ~$3.50 | 1M requests |
| VPC Link | ~$22 | Per VPC Link |
| Network Load Balancer | ~$16 | Required for REST API |
| Application Load Balancer | ~$20 | Includes data processing |
| Fargate Tasks (2x) | ~$30 | 0.25 vCPU, 0.5 GB each |
| DynamoDB | ~$5 | On-demand, low traffic |
| CloudFront | ~$1 | 1GB transfer |
| S3 Storage | ~$0.50 | React app assets |
| ECR Storage | ~$1 | Container images |
| CloudWatch Logs | ~$5 | 7-day retention |
| **Total** | **~$136/month** | Development configuration |

**Note**: Using HTTP API (v2) instead of REST API (v1) would save ~$16/month by eliminating the NLB requirement.

## Related Documentation

- [Main README](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/crud-api-rest/README.md)
- [API Gateway v1 Module](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/api-gateway-v1)
- [DynamoDB Module](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/dynamodb)
- [CloudFront + S3 Module](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/cloudfront-s3)
- [ECS Module](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/ecs)
