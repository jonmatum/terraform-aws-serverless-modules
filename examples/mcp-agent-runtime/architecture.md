# MCP Agent Runtime Architecture

This document provides a detailed architecture view of the MCP (Model Context Protocol) agent runtime on ECS Fargate.

## High-Level Architecture

```mermaid
graph TB
    subgraph "Client"
        Agent[AI Agent/Client]
    end

    subgraph "AWS Bedrock AgentCore"
        Gateway[AgentCore Gateway<br/>IAM Authentication]
    end

    subgraph "Public Subnet"
        ALB[Application Load Balancer<br/>HTTPS Required]
    end

    subgraph "Private Subnet"
        ECS1[ECS Task 1<br/>MCP Server]
        ECS2[ECS Task 2<br/>MCP Server]
    end

    subgraph "Services"
        ECR[ECR Repository<br/>MCP Server Image]
        CW[CloudWatch<br/>Logs & Metrics]
    end

    Agent --> Gateway
    Gateway -.->|Requires HTTPS| ALB
    ALB --> ECS1
    ALB --> ECS2
    ECS1 -.-> ECR
    ECS2 -.-> ECR
    ECS1 -.-> CW
    ECS2 -.-> CW
```

## MCP Protocol Flow

```mermaid
sequenceDiagram
    participant Agent as AI Agent
    participant Gateway as AgentCore Gateway
    participant ALB
    participant ECS as MCP Server

    Agent->>Gateway: MCP Request + IAM Auth
    Gateway->>Gateway: Validate IAM Credentials
    Gateway->>ALB: Forward to HTTPS Endpoint
    ALB->>ALB: Health Check
    ALB->>ECS: Route to Healthy Task
    ECS->>ECS: Process MCP Protocol
    ECS->>ALB: MCP Response
    ALB->>Gateway: Return Response
    Gateway->>Agent: MCP Response
```

## Terraform Resources

```mermaid
graph TB
    subgraph "VPC Module"
        VPC[VPC]
        PubSub[Public Subnets]
        PrivSub[Private Subnets]
        NAT[NAT Gateway]
    end

    subgraph "ECR Module"
        ECR[ECR Repository]
        Lifecycle[Lifecycle Policy]
    end

    subgraph "ALB Module"
        ALB[Application LB<br/>HTTPS Listener]
        TG[Target Group]
        Cert[ACM Certificate]
    end

    subgraph "ECS Module"
        Cluster[ECS Cluster]
        Service[ECS Service<br/>MCP Server]
        TaskDef[Task Definition]
        AutoScale[Auto Scaling<br/>2-4 tasks]
    end

    subgraph "AgentCore"
        Gateway[AgentCore Gateway]
        Target[Gateway Target<br/>HTTPS Endpoint]
    end

    subgraph "Monitoring"
        CWLogs[CloudWatch Logs]
        CWAlarms[CloudWatch Alarms]
    end

    ALB --> TG
    TG --> Service
    Service --> TaskDef
    TaskDef --> ECR
    Gateway --> Target
    Target -.->|HTTPS Required| ALB
    Service -.-> CWLogs
    ALB -.-> CWAlarms
```

## Deployment Flow

```mermaid
graph TB
    Start[Run deploy.sh] --> Build[Build MCP Server Image]
    Build --> Push[Push to ECR]
    Push --> TF[Terraform Apply]
    TF --> CreateVPC[Create VPC]
    CreateVPC --> CreateECR[Create ECR]
    CreateECR --> CreateALB[Create ALB with HTTPS]
    CreateALB --> CreateECS[Create ECS Service]
    CreateECS --> CreateGateway[Create AgentCore Gateway]
    CreateGateway --> Health[Health Check]
    Health --> Ready[Deployment Complete]
```

## Cost Breakdown

| Component | Monthly Cost | Notes |
|-----------|--------------|-------|
| NAT Gateway | ~$32 | Single NAT for dev |
| Fargate Tasks (2x) | ~$30 | 0.25 vCPU, 0.5 GB each |
| ALB | ~$20 | Includes data processing |
| AgentCore Gateway | ~$0 | Pay per request |
| ECR Storage | ~$1 | Container images |
| CloudWatch Logs | ~$5 | 7-day retention |
| ACM Certificate | ~$0 | Free for public certs |
| **Total** | **~$88/month** | Development configuration |

## Production Considerations

- Configure HTTPS listener on ALB with ACM certificate
- Use custom domain with Route 53
- Enable WAF for additional security
- Implement request throttling
- Set up CloudWatch alarms for monitoring
- Use Secrets Manager for sensitive configuration

## Related Documentation

- [Main README](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/mcp-agent-runtime/README.md)
- [VPC Module](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/vpc)
- [ECS Module](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/ecs)
- [ALB Module](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/modules/alb)
- [MCP Protocol Specification](https://modelcontextprotocol.io/)
