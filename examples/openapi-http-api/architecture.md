# OpenAPI HTTP API Architecture

This document provides a detailed architecture view of the OpenAPI HTTP API example with automatic schema import.

## High-Level Architecture

```mermaid
graph TB
    subgraph "Client"
        User[API Client]
    end
    
    subgraph "API Gateway HTTP API"
        APIGW[API Gateway HTTP API v2<br/>OpenAPI 3.0]
        VPCLink[VPC Link]
    end
    
    subgraph "Private Network"
        NLB[Network Load Balancer]
        ECS[ECS Fargate<br/>FastAPI App]
    end
    
    subgraph "Schema"
        OpenAPI[OpenAPI 3.0 Schema<br/>Auto-generated]
    end
    
    User --> APIGW
    APIGW --> VPCLink
    VPCLink --> NLB
    NLB --> ECS
    ECS -.-> OpenAPI
    OpenAPI -.-> APIGW
```

## OpenAPI Integration Flow

```mermaid
sequenceDiagram
    participant FastAPI
    participant Docker
    participant Terraform
    participant APIGW as API Gateway
    
    Note over FastAPI,APIGW: Deployment Time
    FastAPI->>Docker: Generate OpenAPI Schema
    Docker->>Terraform: Export openapi.json
    Terraform->>APIGW: Import Schema
    APIGW->>APIGW: Create Routes
    APIGW->>APIGW: Configure Integrations
    
    Note over FastAPI,APIGW: Runtime
    Client->>APIGW: API Request
    APIGW->>APIGW: Validate Against Schema
    APIGW->>FastAPI: Forward Request
    FastAPI->>APIGW: Response
    APIGW->>Client: Validated Response
```

## Terraform Resources

```mermaid
graph TB
    subgraph "VPC Module"
        VPC[VPC]
        PrivSub[Private Subnets]
        NAT[NAT Gateway]
    end
    
    subgraph "API Gateway Module"
        APIGW[HTTP API v2]
        Schema[OpenAPI 3.0 Import]
        VPCLink[VPC Link]
        Routes[Auto-generated Routes]
    end
    
    subgraph "Network Load Balancer"
        NLB[NLB]
        NLBListener[NLB Listener]
        NLBTarget[NLB Target Group]
    end
    
    subgraph "ECS Module"
        Cluster[ECS Cluster]
        Service[ECS Service<br/>FastAPI]
        TaskDef[Task Definition]
    end
    
    subgraph "ECR Module"
        ECR[ECR Repository]
    end
    
    Schema --> APIGW
    APIGW --> Routes
    APIGW --> VPCLink
    VPCLink --> NLB
    NLB --> NLBListener
    NLBListener --> NLBTarget
    NLBTarget --> Service
    Service --> TaskDef
    TaskDef --> ECR
```

## Request Validation

```mermaid
sequenceDiagram
    participant Client
    participant APIGW as API Gateway
    participant ECS as FastAPI
    
    Note over Client,ECS: Valid Request
    Client->>APIGW: POST /users {valid data}
    APIGW->>APIGW: Validate Against OpenAPI
    APIGW->>ECS: Forward Request
    ECS->>APIGW: 201 Created
    APIGW->>Client: 201 Created
    
    Note over Client,ECS: Invalid Request
    Client->>APIGW: POST /users {invalid data}
    APIGW->>APIGW: Validate Against OpenAPI
    APIGW->>Client: 400 Bad Request
    Note over ECS: Request never reaches backend
```

## Cost Breakdown

| Component | Monthly Cost | Notes |
|-----------|--------------|-------|
| NAT Gateway | ~$32 | Single NAT for dev |
| API Gateway HTTP API | ~$1 | 1M requests |
| VPC Link | ~$22 | Per VPC Link |
| Network Load Balancer | ~$16 | Required for HTTP API |
| Fargate Tasks (2x) | ~$30 | 0.25 vCPU, 0.5 GB each |
| ECR Storage | ~$1 | Container images |
| CloudWatch Logs | ~$5 | 7-day retention |
| **Total** | **~$107/month** | Development configuration |

## Related Documentation

- [Main README](./README.md)
- [API Gateway v2 Module](../../modules/api-gateway/)
- [ECS Module](../../modules/ecs/)
- [OpenAPI 3.0 Specification](https://spec.openapis.org/oas/v3.0.0)
