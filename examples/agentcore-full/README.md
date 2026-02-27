# AgentCore Full Example

Comprehensive Amazon Bedrock AgentCore example demonstrating all capabilities:

- **Multiple Gateway Targets**: ECS and Lambda-based MCP servers
- **Knowledge Base**: Document retrieval with OpenSearch Serverless
- **Bedrock Agent**: AI assistant with action groups
- **Guardrails**: Content filtering and topic policies
- **Custom Actions**: Lambda-based API integrations

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    AgentCore Gateway                         │
│                    (IAM Auth + Guardrails)                   │
└────────┬────────────┬──────────────────────────────────────┘
         │            │              
    ┌────▼────┐  ┌───▼────┐   
    │ ECS MCP │  │Lambda  │   
    │ Server  │  │  MCP   │   
    │         │  │ Server │   
    │ Node.js │  │ Python │   
    │ Fargate │  │Function│   
    │         │  │  URL   │   
    └─────────┘  └────────┘   

Additional Components (accessed directly):
┌─────────────┐ ┌───────────────┐
│ Knowledge   │ │ Bedrock Agent │
│   Base      │ │               │
│ • S3 Docs   │ │ • Claude 3    │
│ • OpenSrch  │ │ • Actions     │
│ • Titan     │ │ • KB Access   │
└─────────────┘ └───────┬───────┘
                        │
                   ┌────▼────────┐
                   │   Lambda    │
                   │   Actions   │
                   │             │
                   │ • Weather   │
                   │ • Database  │
                   └─────────────┘
```

## Features

### 1. Multiple MCP Servers
- **ECS-based**: Scalable Node.js MCP server on Fargate
- **Lambda-based**: Serverless Python MCP server

### 2. Knowledge Base
- OpenSearch Serverless for vector storage
- Titan embeddings for semantic search
- S3 data source for documents
- Versioning and lifecycle policies

### 3. Bedrock Agent
- Claude 3 Sonnet foundation model
- Custom action groups for API calls
- Memory and conversation management

### 4. Guardrails
- Content filtering (hate, violence, etc.)
- Topic blocking (financial advice, medical, etc.)
- PII redaction

### 5. Action Groups
- Lambda-based API integrations
- Weather API example
- Database query example

### 6. Production-Ready (AWS Well-Architected)

**Operational Excellence:**
- CloudWatch alarms for all components
- Centralized logging
- X-Ray tracing (optional)
- Automated deployment

**Security:**
- IAM authentication
- Guardrails for content filtering
- VPC with public/private subnets
- Encryption at rest and in transit
- VPC Flow Logs (optional)
- S3 versioning for backups

**Reliability:**
- Multi-AZ deployment
- Auto-scaling (ECS and Lambda)
- Dead Letter Queues
- Retry policies
- Health checks

**Performance:**
- Fargate Spot for cost/performance
- Lambda auto-scaling
- OpenSearch Serverless

**Cost Optimization:**
- Pay-per-use Lambda
- Fargate Spot option
- S3 lifecycle policies
- Single NAT Gateway (dev)

## Prerequisites

**Required:**
- AWS Provider >= 6.18.0
- Terraform >= 1.0
- Docker
- AWS CLI configured
- **OpenSearch Serverless subscription** (Knowledge Base requires this service)
- **Bedrock model access** (Claude 3 Sonnet, Titan Embeddings)

**Optional:**
- ACM certificate for HTTPS (required for ECS Gateway Target only)

**Note:** This example requires OpenSearch Serverless which may not be available in all AWS accounts. If you encounter "SubscriptionRequiredException", this service is not enabled for your account.

## Quick Start

```bash
# 1. Create ACM certificate
aws acm request-certificate \
  --domain-name your-domain.com \
  --validation-method DNS

# 2. Deploy infrastructure
cd terraform
terraform init
terraform apply -var="certificate_arn=arn:aws:acm:..."

# 3. Upload documents to Knowledge Base
aws s3 cp docs/ s3://$(terraform output -raw kb_bucket_name)/docs/ --recursive

# 4. Sync Knowledge Base
aws bedrock-agent start-ingestion-job \
  --knowledge-base-id $(terraform output -raw knowledge_base_id) \
  --data-source-id $(terraform output -raw data_source_id)
```

## Testing

```bash
# Get Gateway ID
GATEWAY_ID=$(terraform output -raw gateway_id)

# Test MCP server via Gateway
aws bedrock-agentcore-runtime invoke-gateway \
  --gateway-identifier $GATEWAY_ID \
  --request-body '{"method":"tools/list"}' \
  --region us-east-1

# Test Knowledge Base
aws bedrock-agent-runtime retrieve \
  --knowledge-base-id $(terraform output -raw knowledge_base_id) \
  --retrieval-query '{"text":"What is our return policy?"}'

# Test Agent
aws bedrock-agent-runtime invoke-agent \
  --agent-id $(terraform output -raw agent_id) \
  --agent-alias-id $(terraform output -raw agent_alias_id) \
  --session-id test-session \
  --input-text "What's the weather in Seattle?"
```

## Configuration

### Guardrails

Edit `terraform/guardrails.tf` to customize:
- Content filters (hate, violence, sexual, etc.)
- Blocked topics
- PII redaction rules
- Sensitive information filters

### Monitoring

Enable CloudWatch alarms and notifications:

```hcl
# Create SNS topic and email subscription
create_alarm_topic = true
alarm_email        = "your-email@example.com"

# Or use existing SNS topic
alarm_sns_topic_arn = "arn:aws:sns:us-east-1:123456789012:alerts"
```

### Security

Enable additional security features:

```hcl
# VPC Flow Logs for network monitoring
enable_vpc_flow_logs = true

# X-Ray tracing for Lambda functions
enable_xray = true
```

### Reliability

Configure Lambda reliability features:

```hcl
# Enable Dead Letter Queues
enable_dlq = true
```

### Knowledge Base

Add documents to `docs/` directory before deployment. Supported formats:
- PDF
- TXT
- MD
- HTML
- DOC/DOCX

### Agent Actions

Add custom actions in `action-lambda/actions.py`:

```python
def handle_action(action_name, parameters):
    if action_name == "get_weather":
        return get_weather(parameters["location"])
    elif action_name == "query_database":
        return query_db(parameters["query"])
```

## Cost Estimate

**Monthly costs** (assuming moderate usage):
- AgentCore Gateway: $0 (pay per request)
- ECS Fargate: ~$15 (1 task, 0.25 vCPU, 0.5 GB)
- Lambda: ~$5 (100K invocations)
- OpenSearch Serverless: ~$700 (1 OCU)
- Bedrock Agent: Pay per use
- Knowledge Base: Pay per query
- S3: ~$1

**Total: ~$721/month** (OpenSearch is the main cost)

**Cost optimization**:
- Use Lambda-only MCP servers (no ECS): Save $15/month
- Reduce OpenSearch OCUs for dev: Configure minimum OCUs
- Use on-demand pricing for Bedrock models

## Production Considerations

1. **HTTPS Required**: Gateway Targets require HTTPS endpoints
2. **Guardrails**: Enable for production to filter harmful content
3. **Monitoring**: CloudWatch alarms for all components
4. **Scaling**: Configure auto-scaling for ECS and Lambda
5. **Security**: Use VPC endpoints, encryption at rest/transit
6. **Backup**: Enable PITR for OpenSearch, versioning for S3

## Cleanup

```bash
# Delete Knowledge Base data
aws s3 rm s3://$(terraform output -raw kb_bucket_name) --recursive

# Destroy infrastructure
terraform destroy -auto-approve
```

## Architecture Details

See [architecture.md](architecture.md) for detailed diagrams and explanations.

## Next Steps

- Add more MCP tools to servers
- Integrate with your APIs via action groups
- Add more documents to Knowledge Base
- Customize guardrails for your use case
- Add custom authorizer for advanced auth
