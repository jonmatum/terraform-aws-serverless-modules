# ECS App Architecture

This document provides a detailed architecture view of the ECS application example.

## High-Level Architecture

```mermaid
graph TB
    subgraph "Internet"
        Client[Client]
    end

    subgraph "AWS Cloud"
        subgraph "Public Subnet"
            ALB[Application Load Balancer]
            NAT[NAT Gateway]
        end

        subgraph "Private Subnet"
            ECS1[ECS Task 1<br/>FastAPI App]
            ECS2[ECS Task 2<br/>FastAPI App]
        end

        subgraph "Services"
            ECR[ECR Repository<br/>Container Images]
            CW[CloudWatch<br/>Logs & Metrics]
            WAF[AWS WAF<br/>Rate Limiting]
        end
    end

    Client --> WAF
    WAF --> ALB
    ALB --> ECS1
    ALB --> ECS2
    ECS1 --> NAT
    ECS2 --> NAT
    NAT --> Internet[Internet]
    ECS1 -.-> ECR
    ECS2 -.-> ECR
    ECS1 -.-> CW
    ECS2 -.-> CW
```

## Terraform Resources

```mermaid
graph TB
    subgraph "VPC Module"
        VPC[VPC<br/>10.0.0.0/16]
        PubSub[Public Subnets<br/>2 AZs]
        PrivSub[Private Subnets<br/>2 AZs]
        IGW[Internet Gateway]
        NAT1[NAT Gateway]
    end

    subgraph "ECR Module"
        ECR[ECR Repository<br/>Encrypted]
        Lifecycle[Lifecycle Policy<br/>Keep 5 images]
    end

    subgraph "ALB Module"
        ALB[Application LB]
        TG[Target Group<br/>Health Checks]
        Listener[HTTP Listener<br/>Port 80]
    end

    subgraph "ECS Module"
        Cluster[ECS Cluster]
        Service[ECS Service<br/>Fargate]
        TaskDef[Task Definition<br/>FastAPI Container]
        AutoScale[Auto Scaling<br/>2-4 tasks]
    end

    subgraph "WAF Module"
        WAF[Web ACL]
        RateLimit[Rate Limit Rule<br/>2000 req/5min]
        IPReputation[IP Reputation Rule]
    end

    subgraph "CloudWatch Module"
        CPUAlarm[CPU Alarm<br/>>80%]
        MemAlarm[Memory Alarm<br/>>80%]
        TargetAlarm[Unhealthy Target Alarm]
    end

    VPC --> PubSub
    VPC --> PrivSub
    PubSub --> IGW
    PubSub --> NAT1
    PrivSub --> NAT1

    ALB --> TG
    ALB --> Listener
    WAF --> ALB

    Service --> TaskDef
    Service --> AutoScale
    Cluster --> Service
    TaskDef --> ECR

    TG --> Service
```

## Request Flow

```mermaid
sequenceDiagram
    participant Client
    participant WAF
    participant ALB
    participant ECS
    participant App

    Client->>WAF: HTTP Request
    WAF->>WAF: Check Rate Limit
    WAF->>WAF: Check IP Reputation
    WAF->>ALB: Forward Request
    ALB->>ALB: Health Check
    ALB->>ECS: Route to Healthy Task
    ECS->>App: Execute Request
    App->>ECS: Response
    ECS->>ALB: Return Response
    ALB->>WAF: Forward Response
    WAF->>Client: HTTP Response
```

## Auto-Scaling Behavior

```mermaid
graph LR
    subgraph "Scaling Triggers"
        CPU[CPU > 70%]
        MEM[Memory > 80%]
    end

    subgraph "Current State"
        Tasks[2 Tasks Running]
    end

    subgraph "Scaling Actions"
        ScaleUp[Scale Up<br/>Add 1 Task]
        ScaleDown[Scale Down<br/>Remove 1 Task]
    end

    subgraph "Limits"
        Min[Min: 2 Tasks]
        Max[Max: 4 Tasks]
    end

    CPU --> ScaleUp
    MEM --> ScaleUp
    ScaleUp --> Tasks
    Tasks --> ScaleDown
    Min -.-> Tasks
    Max -.-> Tasks
```

## Monitoring & Alarms

```mermaid
graph TB
    subgraph "Metrics"
        CPUMetric[ECS CPU Utilization]
        MemMetric[ECS Memory Utilization]
        ALBMetric[ALB Response Time]
        TargetMetric[Unhealthy Targets]
    end

    subgraph "Alarms"
        CPUAlarm[CPU > 80%]
        MemAlarm[Memory > 80%]
        ResponseAlarm[Response > 1s]
        TargetAlarm[Unhealthy > 0]
    end

    subgraph "Actions"
        SNS[SNS Topic<br/>Optional]
    end

    CPUMetric --> CPUAlarm
    MemMetric --> MemAlarm
    ALBMetric --> ResponseAlarm
    TargetMetric --> TargetAlarm

    CPUAlarm -.-> SNS
    MemAlarm -.-> SNS
    ResponseAlarm -.-> SNS
    TargetAlarm -.-> SNS
```

## Deployment Flow

```mermaid
graph TB
    Start[Run deploy.sh] --> Build[Build Docker Image]
    Build --> Tag[Tag Image]
    Tag --> Push[Push to ECR]
    Push --> TF[Terraform Apply]
    TF --> CreateVPC[Create VPC]
    CreateVPC --> CreateECR[Create ECR]
    CreateECR --> CreateALB[Create ALB]
    CreateALB --> CreateECS[Create ECS Service]
    CreateECS --> CreateWAF[Create WAF]
    CreateWAF --> CreateAlarms[Create CloudWatch Alarms]
    CreateAlarms --> Health[Health Check]
    Health --> Ready[Deployment Complete]
```

## Cost Breakdown

| Component | Monthly Cost | Notes |
|-----------|--------------|-------|
| NAT Gateway | ~$32 | Single NAT for dev |
| Fargate Tasks (2x) | ~$30 | 0.25 vCPU, 0.5 GB each |
| ALB | ~$20 | Includes data processing |
| ECR Storage | ~$1 | 5 images retained |
| CloudWatch Logs | ~$5 | 7-day retention |
| Data Transfer | Variable | Depends on traffic |
| **Total** | **~$88/month** | Development configuration |

## Related Documentation

- [Main README](./README.md)
- [VPC Module](../../modules/vpc/)
- [ECS Module](../../modules/ecs/)
- [ALB Module](../../modules/alb/)
- [WAF Module](../../modules/waf/)
