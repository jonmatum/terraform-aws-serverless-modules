# Multi-Service API Gateway Architecture

This document provides a detailed architecture view of the multi-service API Gateway example.

## High-Level Architecture

```mermaid
graph TB
    subgraph "Internet"
        Client[Client]
    end
    
    subgraph "AWS Cloud"
        subgraph "API Gateway"
            APIGW[API Gateway HTTP API]
            VPCLink[VPC Link]
        end
        
        subgraph "Public Subnet"
            NAT[NAT Gateway]
        end
        
        subgraph "Private Subnet"
            ALB1[ALB FastAPI<br/>Port 8000]
            ALB2[ALB MCP<br/>Port 3000]
            ECS1[ECS FastAPI Service<br/>2-4 tasks]
            ECS2[ECS MCP Service<br/>2-4 tasks]
        end
        
        subgraph "Services"
            ECR1[ECR FastAPI<br/>Repository]
            ECR2[ECR MCP<br/>Repository]
            CW[CloudWatch<br/>Logs & Metrics]
        end
    end
    
    Client --> APIGW
    APIGW --> VPCLink
    VPCLink --> ALB1
    VPCLink --> ALB2
    ALB1 --> ECS1
    ALB2 --> ECS2
    ECS1 --> NAT
    ECS2 --> NAT
    NAT --> Internet[Internet]
    ECS1 -.-> ECR1
    ECS2 -.-> ECR2
    ECS1 -.-> CW
    ECS2 -.-> CW
```

## API Gateway Routing

```mermaid
graph LR
    subgraph "Client Requests"
        ReqFastAPI[GET /api/fastapi/*]
        ReqMCP[GET /api/mcp/*]
    end
    
    subgraph "API Gateway"
        APIGW[API Gateway<br/>HTTP API]
    end
    
    subgraph "VPC Link"
        VPCLink[VPC Link<br/>Private Connection]
    end
    
    subgraph "Target Services"
        ALB1[ALB FastAPI<br/>:8000]
        ALB2[ALB MCP<br/>:3000]
    end
    
    ReqFastAPI --> APIGW
    ReqMCP --> APIGW
    APIGW --> VPCLink
    VPCLink --> ALB1
    VPCLink --> ALB2
```

## Terraform Resources

```mermaid
graph TB
    subgraph "VPC Module"
        VPC[VPC<br/>10.0.0.0/16]
        PubSub[Public Subnets<br/>2 AZs]
        PrivSub[Private Subnets<br/>2 AZs]
        NAT1[NAT Gateway]
    end
    
    subgraph "API Gateway Module"
        APIGW[API Gateway v2<br/>HTTP API]
        VPCLink[VPC Link]
        Routes[Routes<br/>/api/fastapi/*<br/>/api/mcp/*]
        Integration[VPC Link Integration]
    end
    
    subgraph "FastAPI Service"
        ECR1[ECR Repository]
        ALB1[ALB FastAPI]
        ECS1[ECS Service<br/>FastAPI]
        TG1[Target Group<br/>:8000]
    end
    
    subgraph "MCP Service"
        ECR2[ECR Repository]
        ALB2[ALB MCP]
        ECS2[ECS Service<br/>MCP]
        TG2[Target Group<br/>:3000]
    end
    
    subgraph "Monitoring"
        CWLogs[CloudWatch Logs]
        CWAlarms[CloudWatch Alarms]
    end
    
    VPC --> PrivSub
    VPC --> PubSub
    PubSub --> NAT1
    
    APIGW --> Routes
    APIGW --> VPCLink
    Routes --> Integration
    Integration --> VPCLink
    VPCLink --> ALB1
    VPCLink --> ALB2
    
    ALB1 --> TG1
    TG1 --> ECS1
    ECS1 --> ECR1
    
    ALB2 --> TG2
    TG2 --> ECS2
    ECS2 --> ECR2
    
    ECS1 -.-> CWLogs
    ECS2 -.-> CWLogs
    ALB1 -.-> CWAlarms
    ALB2 -.-> CWAlarms
```

## Request Flow

```mermaid
sequenceDiagram
    participant Client
    participant APIGW as API Gateway
    participant VPCLink as VPC Link
    participant ALB as Private ALB
    participant ECS as ECS Service
    participant App
    
    Client->>APIGW: GET /api/fastapi/health
    APIGW->>APIGW: Route Matching
    APIGW->>VPCLink: Forward to VPC Link
    VPCLink->>ALB: Private Connection
    ALB->>ALB: Health Check
    ALB->>ECS: Route to Task
    ECS->>App: Execute Request
    App->>ECS: Response
    ECS->>ALB: Return Response
    ALB->>VPCLink: Forward Response
    VPCLink->>APIGW: Return Response
    APIGW->>Client: HTTP 200 OK
```

## Service Isolation

```mermaid
graph TB
    subgraph "FastAPI Service"
        FastAPI_ALB[Dedicated ALB]
        FastAPI_TG[Target Group :8000]
        FastAPI_ECS[ECS Tasks<br/>FastAPI Container]
        FastAPI_ECR[ECR Repository]
        FastAPI_Scale[Auto Scaling<br/>2-4 tasks]
    end
    
    subgraph "MCP Service"
        MCP_ALB[Dedicated ALB]
        MCP_TG[Target Group :3000]
        MCP_ECS[ECS Tasks<br/>MCP Container]
        MCP_ECR[ECR Repository]
        MCP_Scale[Auto Scaling<br/>2-4 tasks]
    end
    
    subgraph "Shared Infrastructure"
        VPC[VPC]
        Subnets[Private Subnets]
        NAT[NAT Gateway]
        CW[CloudWatch]
    end
    
    FastAPI_ALB --> FastAPI_TG
    FastAPI_TG --> FastAPI_ECS
    FastAPI_ECS --> FastAPI_ECR
    FastAPI_ECS --> FastAPI_Scale
    
    MCP_ALB --> MCP_TG
    MCP_TG --> MCP_ECS
    MCP_ECS --> MCP_ECR
    MCP_ECS --> MCP_Scale
    
    FastAPI_ECS -.-> VPC
    MCP_ECS -.-> VPC
    VPC --> Subnets
    Subnets --> NAT
    FastAPI_ECS -.-> CW
    MCP_ECS -.-> CW
```

## Deployment Strategies

```mermaid
graph TB
    Start[Run deploy.sh] --> BuildAll[Build Both Images]
    
    BuildAll --> BuildFastAPI[Build FastAPI Image]
    BuildAll --> BuildMCP[Build MCP Image]
    
    BuildFastAPI --> PushFastAPI[Push to ECR FastAPI]
    BuildMCP --> PushMCP[Push to ECR MCP]
    
    PushFastAPI --> TF[Terraform Apply]
    PushMCP --> TF
    
    TF --> CreateInfra[Create Shared Infrastructure]
    CreateInfra --> CreateFastAPI[Deploy FastAPI Service]
    CreateInfra --> CreateMCP[Deploy MCP Service]
    
    CreateFastAPI --> HealthFastAPI[Health Check FastAPI]
    CreateMCP --> HealthMCP[Health Check MCP]
    
    HealthFastAPI --> Ready[Deployment Complete]
    HealthMCP --> Ready
    
    style BuildFastAPI fill:#90EE90
    style BuildMCP fill:#87CEEB
    style CreateFastAPI fill:#90EE90
    style CreateMCP fill:#87CEEB
```

## Redeploy Flow

```mermaid
graph LR
    Start[Run redeploy.sh] --> Check{Service Specified?}
    
    Check -->|No| Both[Redeploy Both]
    Check -->|fastapi| FastAPI[Redeploy FastAPI Only]
    Check -->|mcp| MCP[Redeploy MCP Only]
    
    Both --> BuildBoth[Build Both Images]
    FastAPI --> BuildFastAPI[Build FastAPI Image]
    MCP --> BuildMCP[Build MCP Image]
    
    BuildBoth --> UpdateBoth[Update Both ECS Services]
    BuildFastAPI --> UpdateFastAPI[Update FastAPI ECS]
    BuildMCP --> UpdateMCP[Update MCP ECS]
    
    UpdateBoth --> Done[Complete]
    UpdateFastAPI --> Done
    UpdateMCP --> Done
```

## Cost Breakdown

| Component | Monthly Cost | Notes |
|-----------|--------------|-------|
| NAT Gateway | ~$32 | Single NAT for dev |
| API Gateway | ~$3.50 | 1M requests |
| VPC Link | ~$22 | Per VPC Link |
| Fargate FastAPI (2x) | ~$30 | 0.25 vCPU, 0.5 GB each |
| Fargate MCP (2x) | ~$30 | 0.25 vCPU, 0.5 GB each |
| ALB FastAPI | ~$20 | Includes data processing |
| ALB MCP | ~$20 | Includes data processing |
| ECR Storage | ~$2 | 5 images per service |
| CloudWatch Logs | ~$10 | 7-day retention |
| Data Transfer | Variable | Depends on traffic |
| **Total** | **~$169/month** | Development configuration |

## Related Documentation

- [Main README](./README.md)
- [VPC Module](../../modules/vpc/)
- [API Gateway Module](../../modules/api-gateway/)
- [ECS Module](../../modules/ecs/)
- [ALB Module](../../modules/alb/)
