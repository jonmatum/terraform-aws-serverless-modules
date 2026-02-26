# AgentCore Full - Architecture

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Amazon Bedrock                               │
│                    AgentCore Gateway                             │
│                                                                   │
│  Features:                                                        │
│  • IAM Authentication                                             │
│  • Content Filtering (Guardrails)                                │
│  • Topic Blocking                                                 │
│  • PII Redaction                                                  │
└────────┬────────────┬──────────────┬────────────┬───────────────┘
         │            │              │            │
    ┌────▼────┐  ┌───▼────┐   ┌─────▼─────┐ ┌───▼────────────┐
    │ ECS MCP │  │Lambda  │   │ Knowledge │ │ Bedrock Agent  │
    │ Server  │  │  MCP   │   │   Base    │ │                │
    │         │  │ Server │   │           │ │ • Claude 3     │
    │ Node.js │  │ Python │   │ • S3 Docs │ │ • Action Groups│
    │ Fargate │  │Function│   │ • OpenSrch│ │ • KB Access    │
    │         │  │  URL   │   │ • Titan   │ │                │
    └─────────┘  └────────┘   └───────────┘ └────────┬───────┘
                                                      │
                                                 ┌────▼────────┐
                                                 │   Lambda    │
                                                 │   Actions   │
                                                 │             │
                                                 │ • Weather   │
                                                 │ • Database  │
                                                 └─────────────┘
```

## Component Details

### 1. AgentCore Gateway
- **Purpose**: Central entry point for all AI interactions
- **Authentication**: AWS IAM (SigV4)
- **Protocol**: Model Context Protocol (MCP)
- **Guardrails**: Content filtering, topic blocking, PII redaction

### 2. MCP Servers

#### ECS MCP Server
- **Runtime**: Node.js on ECS Fargate
- **Scaling**: Auto-scaling 1-4 tasks
- **Tools**: 
  - `echo` - Echo messages
  - `get_system_info` - Container info
  - `calculate` - Math operations
- **Health Check**: `/health` endpoint
- **Load Balancer**: Application Load Balancer with HTTPS

#### Lambda MCP Server
- **Runtime**: Python 3.11 on Lambda
- **Invocation**: Function URL with IAM auth
- **Tools**:
  - `reverse_string` - String reversal
  - `get_lambda_info` - Function metadata
- **Cost**: Pay per invocation

### 3. Knowledge Base
- **Storage**: OpenSearch Serverless (vector search)
- **Embeddings**: Amazon Titan Embed Text v1
- **Data Source**: S3 bucket with documents
- **Documents**: 
  - Return policy
  - Product catalog
  - FAQ
- **Sync**: Automatic ingestion jobs

### 4. Bedrock Agent
- **Model**: Claude 3 Sonnet
- **Capabilities**:
  - Natural language understanding
  - Knowledge base queries
  - Action group execution
  - Conversation memory
- **Action Groups**:
  - Weather API (simulated)
  - Database queries (simulated)

### 5. Action Lambda
- **Purpose**: Execute external API calls for Agent
- **Format**: Bedrock Agent action group format
- **APIs**:
  - `GET /weather?location=X` - Weather info
  - `POST /database/query` - Database queries

## Data Flow

### MCP Tool Invocation
```
User → Gateway → MCP Server → Tool Execution → Response
```

### Knowledge Base Query
```
User → Gateway → Knowledge Base → OpenSearch → S3 Docs → Response
```

### Agent Conversation
```
User → Gateway → Agent → Claude 3 → [KB Query | Action] → Response
```

### Agent with Action
```
User → Gateway → Agent → Action Lambda → External API → Response
```

## Security

### Network
- VPC with public/private subnets
- NAT Gateway for outbound traffic
- Security groups restrict access
- VPC endpoints for AWS services

### IAM
- Least privilege roles for each component
- Service-specific assume role policies
- Resource-based policies for cross-service access

### Data
- Encryption at rest (S3, OpenSearch)
- Encryption in transit (HTTPS, TLS)
- PII redaction via guardrails

### Guardrails
- Content filters: Hate, violence, sexual, insults
- Topic blocking: Financial, medical, legal advice
- PII protection: Email, phone, SSN, credit cards
- Word filters: Profanity, confidential terms

## Scaling

### ECS MCP Server
- Auto-scaling based on CPU/memory
- Min: 1 task, Max: 4 tasks
- Fargate Spot for cost optimization

### Lambda Functions
- Automatic scaling
- Concurrent execution limits
- Reserved concurrency (optional)

### OpenSearch Serverless
- Automatic scaling
- OCU-based pricing
- No manual capacity management

## Monitoring

### CloudWatch Logs
- `/ecs/agentcore-full-mcp-ecs` - ECS logs
- `/aws/lambda/agentcore-full-mcp-lambda` - Lambda MCP logs
- `/aws/lambda/agentcore-full-actions` - Action Lambda logs
- `/aws/bedrock-agentcore/*` - Gateway logs

### CloudWatch Metrics
- ECS: CPU, memory, task count
- Lambda: Invocations, duration, errors
- ALB: Request count, latency, errors
- Agent: Invocations, latency

### Alarms
- ECS high CPU/memory
- Lambda errors/throttles
- ALB unhealthy targets
- OpenSearch storage

## Cost Breakdown

### Fixed Costs (Monthly)
- OpenSearch Serverless: ~$700 (1 OCU)
- NAT Gateway: ~$32
- ALB: ~$16

### Variable Costs (per use)
- ECS Fargate: $0.04048/hour per task
- Lambda: $0.20 per 1M requests
- Bedrock Agent: Pay per token
- Knowledge Base: Pay per query
- S3: $0.023 per GB

### Cost Optimization
- Use Lambda-only (no ECS): Save $30/month
- Single NAT Gateway (dev): Save $32/month
- Fargate Spot: Save 50% on compute
- Reduce OpenSearch OCUs: Configure minimum

## Production Considerations

### High Availability
- Multi-AZ deployment
- Multiple NAT Gateways
- ECS tasks across AZs
- OpenSearch multi-AZ

### Performance
- CloudFront for static content
- Lambda provisioned concurrency
- ECS task warm pool
- OpenSearch query caching

### Security
- WAF for ALB
- Secrets Manager for API keys
- KMS for encryption
- VPC Flow Logs

### Compliance
- CloudTrail for audit logs
- Config for compliance
- GuardDuty for threats
- Security Hub for posture

## Deployment

### Prerequisites
- AWS CLI configured
- Docker installed
- Terraform >= 1.0
- ACM certificate (for HTTPS)

### Steps
1. Run `./deploy.sh`
2. Wait for ingestion job
3. Test with provided commands
4. Monitor CloudWatch

### Updates
- Code changes: Rebuild and push images
- Infrastructure: `terraform apply`
- Documents: Upload to S3 and sync KB
- Guardrails: Update and create new version
