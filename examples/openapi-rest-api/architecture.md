# OpenAPI REST API Architecture

This document provides a detailed architecture view of the OpenAPI REST API example with Swagger 2.0 schema import.

## High-Level Architecture

```mermaid
graph TB
    subgraph "Client"
        User[API Client]
    end
    
    subgraph "API Gateway REST API"
        APIGW[API Gateway REST API v1<br/>Swagger 2.0]
        VPCLink[VPC Link]
    end
    
    subgraph "Private Network"
        NLB[Network Load Balancer<br/>Required for REST API]
        ECS[ECS Fargate<br/>FastAPI App]
    end
    
    subgraph "Schema"
        OpenAPI[OpenAPI 3.0 Schema]
        Swagger[Swagger 2.0 Conversion]
    end
    
    User --> APIGW
    APIGW --> VPCLink
    VPCLink --> NLB
    NLB --> ECS
    ECS -.-> OpenAPI
    OpenAPI -.-> Swagger
    Swagger -.-> APIGW
```

## Swagger Integration Flow

```mermaid
sequenceDiagram
    participant FastAPI
    participant Docker
    participant Converter
    participant Terraform
    participant APIGW as API Gateway
    
    Note over FastAPI,APIGW: Deployment Time
    FastAPI->>Docker: Generate OpenAPI 3.0
    Docker->>Converter: Export openapi.json
    Converter->>Terraform: Convert to Swagger 2.0
    Terraform->>APIGW: Import Swagger Spec
    APIGW->>APIGW: Create Resources
    APIGW->>APIGW: Create Methods
    APIGW->>APIGW: Configure Integrations
    
    Note over FastAPI,APIGW: Runtime
    Client->>APIGW: API Request
    APIGW->>APIGW: Validate Against Swagger
    APIGW->>FastAPI: Forward via VPC Link
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
    
    subgraph "API Gateway v1 Module"
        APIGW[REST API]
        Swagger[Swagger 2.0 Import]
        VPCLink[VPC Link]
        Resources[Auto-generated Resources]
        Methods[Auto-generated Methods]
    end
    
    subgraph "Network Load Balancer"
        NLB[NLB<br/>Required for REST API]
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
    
    Swagger --> APIGW
    APIGW --> Resources
    APIGW --> Methods
    APIGW --> VPCLink
    VPCLink --> NLB
    NLB --> NLBListener
    NLBListener --> NLBTarget
    NLBTarget --> Service
    Service --> TaskDef
    TaskDef --> ECR
```

## OpenAPI to Swagger Conversion

```mermaid
graph LR
    subgraph "FastAPI Output"
        OA3[OpenAPI 3.0<br/>Modern Spec]
    end
    
    subgraph "Conversion"
        Convert[Schema Converter<br/>3.0 → 2.0]
    end
    
    subgraph "API Gateway Input"
        Swagger[Swagger 2.0<br/>Legacy Spec]
    end
    
    OA3 --> Convert
    Convert --> Swagger
    
    Note1[Components → Definitions]
    Note2[requestBody → parameters]
    Note3[servers → host + basePath]
    
    style Note1 fill:#f9f9f9
    style Note2 fill:#f9f9f9
    style Note3 fill:#f9f9f9
```

## Cost Breakdown

| Component | Monthly Cost | Notes |
|-----------|--------------|-------|
| NAT Gateway | ~$32 | Single NAT for dev |
| API Gateway REST API | ~$3.50 | 1M requests |
| VPC Link | ~$22 | Per VPC Link |
| Network Load Balancer | ~$16 | Required for REST API |
| Fargate Tasks (2x) | ~$30 | 0.25 vCPU, 0.5 GB each |
| ECR Storage | ~$1 | Container images |
| CloudWatch Logs | ~$5 | 7-day retention |
| **Total** | **~$109/month** | Development configuration |

## Related Documentation

- [Main README](./README.md)
- [API Gateway v1 Module](../../modules/api-gateway-v1/)
- [ECS Module](../../modules/ecs/)
- [Swagger 2.0 Specification](https://swagger.io/specification/v2/)
- [OpenAPI 3.0 Specification](https://spec.openapis.org/oas/v3.0.0)
