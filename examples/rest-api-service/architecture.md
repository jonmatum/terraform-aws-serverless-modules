# REST API Service Architecture

This document provides a detailed architecture view of the private REST API service example.

## High-Level Architecture

```mermaid
graph TB
    subgraph "Client"
        User[API Client]
    end

    subgraph "API Gateway REST API"
        APIGW[API Gateway REST API v1]
        VPCLink[VPC Link]
    end

    subgraph "Private Network"
        NLB[Network Load Balancer<br/>Required for REST API]
        ECS[ECS Fargate<br/>FastAPI Service]
    end

    subgraph "Services"
        ECR[ECR Repository]
        CW[CloudWatch Logs]
    end

    User --> APIGW
    APIGW --> VPCLink
    VPCLink --> NLB
    NLB --> ECS
    ECS -.-> ECR
    ECS -.-> CW
```

## Private API Integration

```mermaid
sequenceDiagram
    participant Client
    participant APIGW as API Gateway
    participant VPCLink as VPC Link
    participant NLB
    participant ECS as FastAPI Service

    Client->>APIGW: GET /api/health
    APIGW->>APIGW: Route Matching
    APIGW->>VPCLink: Forward to VPC Link
    VPCLink->>NLB: Private Connection
    NLB->>NLB: Health Check
    NLB->>ECS: Route to Task
    ECS->>NLB: Response
    NLB->>VPCLink: Return Response
    VPCLink->>APIGW: Forward Response
    APIGW->>Client: HTTP 200 OK
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
        VPCLink[VPC Link]
        Resource[API Resource /api]
        Method[API Method ANY]
        Integration[VPC Link Integration]
    end

    subgraph "Network Load Balancer"
        NLB[NLB<br/>Private Subnets]
        NLBListener[NLB Listener<br/>Port 8000]
        NLBTarget[NLB Target Group]
    end

    subgraph "ECS Module"
        Cluster[ECS Cluster]
        Service[ECS Service<br/>FastAPI]
        TaskDef[Task Definition]
        AutoScale[Auto Scaling]
    end

    subgraph "ECR Module"
        ECR[ECR Repository]
    end

    APIGW --> Resource
    Resource --> Method
    Method --> Integration
    Integration --> VPCLink
    VPCLink --> NLB
    NLB --> NLBListener
    NLBListener --> NLBTarget
    NLBTarget --> Service
    Service --> TaskDef
    Service --> AutoScale
    TaskDef --> ECR
```

## Request Flow

```mermaid
graph LR
    subgraph "Public"
        Client[Client]
        APIGW[API Gateway]
    end

    subgraph "VPC Link"
        VPCLink[VPC Link<br/>Managed ENIs]
    end

    subgraph "Private VPC"
        NLB[NLB<br/>Private Subnets]
        ECS[ECS Tasks<br/>Private Subnets]
    end

    Client -->|HTTPS| APIGW
    APIGW -->|Private Connection| VPCLink
    VPCLink -->|Internal| NLB
    NLB -->|Internal| ECS
```

## Deployment Flow

```mermaid
graph TB
    Start[Run deploy.sh] --> Build[Build FastAPI Image]
    Build --> Push[Push to ECR]
    Push --> TF[Terraform Apply]
    TF --> CreateVPC[Create VPC]
    CreateVPC --> CreateECS[Create ECS Service]
    CreateECS --> CreateNLB[Create NLB]
    CreateNLB --> CreateVPCLink[Create VPC Link]
    CreateVPCLink --> CreateAPIGW[Create API Gateway]
    CreateAPIGW --> Health[Health Check]
    Health --> Ready[Deployment Complete]
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

## Security Considerations

- ECS tasks run in private subnets (no direct internet access)
- NLB is internal-only (not internet-facing)
- VPC Link provides secure connection from API Gateway to VPC
- All traffic stays within AWS network
- IAM roles control access to AWS services
- Security groups restrict network access

## Related Documentation

- [Main README](./README.md)
- [API Gateway v1 Module](../../modules/api-gateway-v1/)
- [ECS Module](../../modules/ecs/)
- [VPC Module](../../modules/vpc/)
