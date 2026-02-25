# MCP Agent Runtime Example

**⚠️ REQUIRES: AWS Provider >= 6.18.0** (for `aws_bedrockagentcore_gateway` resources)

Model Context Protocol (MCP) server running on ECS Fargate, exposed via **Amazon Bedrock AgentCore Gateway**.

## Architecture

```
┌──────────────────────┐
│  AgentCore Gateway   │ (AWS Bedrock AgentCore)
│   MCP Protocol       │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│        ALB           │ (Application Load Balancer)
│     (Internal)       │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│    ECS Fargate       │ (MCP Server Container)
│    (Private)         │
│    - Auto-scale      │
│    - Spot 50%        │
└──────────────────────┘
```

## Components

- **MCP Server**: Node.js application implementing Model Context Protocol
- **ECS Fargate**: Serverless container runtime with auto-scaling
- **ALB**: Load balancer for health checks and traffic distribution
- **AgentCore Gateway**: AWS-native MCP gateway with IAM authentication
- **CloudWatch**: Logs, metrics, and alarms
- **ECR**: Container registry with lifecycle policies

## MCP Tools

The server exposes two example tools:

1. **echo** - Echo back a message
2. **get_system_info** - Get container system information

## Deployment

### Prerequisites

- AWS CLI configured
- Docker installed
- Terraform >= 1.0

### Deploy

```bash
./deploy.sh
```

This will:
1. Create infrastructure (VPC, ECS, ALB, API Gateway)
2. Build and push Docker image to ECR
3. Deploy MCP server to ECS
4. Output test commands

### Custom Configuration

```bash
# Deploy to different region
AWS_REGION=us-west-2 ./deploy.sh

# Deploy with specific image tag
IMAGE_TAG=v1.0.0 ./deploy.sh
```

## Testing

After deployment, test the MCP server:

```bash
# Get Gateway URL
GATEWAY_URL=$(terraform output -raw gateway_url)
GATEWAY_ID=$(terraform output -raw gateway_id)

# Test via AWS CLI (requires AWS IAM authentication)
aws bedrock-agentcore-runtime invoke-gateway \
  --gateway-identifier $GATEWAY_ID \
  --request-body '{"method":"tools/list"}' \
  --region us-east-1

# Call a tool
aws bedrock-agentcore-runtime invoke-gateway \
  --gateway-identifier $GATEWAY_ID \
  --request-body '{"method":"tools/call","params":{"name":"echo","arguments":{"message":"Hello MCP!"}}}' \
  --region us-east-1

# Direct ALB access (for debugging)
curl http://$(terraform output -raw alb_dns_name)/health
```

## MCP Server Development

### Local Development

```bash
cd mcp-server
npm install
npm run dev
```

### Adding New Tools

Edit `mcp-server/src/index.js`:

```javascript
// Register tool
mcpServer.setRequestHandler('tools/list', async () => {
  return {
    tools: [
      // ... existing tools
      {
        name: 'my_new_tool',
        description: 'Description of my tool',
        inputSchema: {
          type: 'object',
          properties: {
            param1: { type: 'string' }
          },
          required: ['param1']
        }
      }
    ]
  };
});

// Handle tool call
mcpServer.setRequestHandler('tools/call', async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case 'my_new_tool':
      return {
        content: [{
          type: 'text',
          text: `Result: ${args.param1}`
        }]
      };
    // ... other cases
  }
});
```

### Redeploy After Changes

```bash
./deploy.sh
```

## Well-Architected Features

### Security
- ✅ Private subnets for ECS tasks
- ✅ Security groups with specific ports
- ✅ VPC endpoints for AWS services
- ✅ IAM roles with least privilege
- ✅ ECR image scanning enabled

### Reliability
- ✅ Multi-AZ deployment
- ✅ Auto-scaling (1-4 tasks)
- ✅ Health checks on ALB and ECS
- ✅ CloudWatch alarms for monitoring

### Operational Excellence
- ✅ Container Insights enabled
- ✅ CloudWatch Logs (30-day retention)
- ✅ X-Ray tracing on API Gateway
- ✅ Access logs for ALB

### Performance
- ✅ Fargate for serverless scaling
- ✅ VPC Link for low-latency access
- ✅ Connection draining on ALB
- ✅ API Gateway throttling

### Cost Optimization
- ✅ Fargate Spot (50% of capacity)
- ✅ Single NAT gateway (dev)
- ✅ ECR lifecycle policies
- ✅ Auto-scaling based on demand

### Sustainability
- ✅ Right-sized containers (256 CPU, 512 MB)
- ✅ Auto-scaling to match demand
- ✅ Efficient networking with VPC endpoints

## Cost Estimate

**Development Environment:**
- ECS Fargate: ~$15/month (1 task, 50% Spot)
- NAT Gateway: ~$32/month (single AZ)
- ALB: ~$16/month
- API Gateway: ~$3.50/1M requests
- **Total: ~$65-70/month**

**Production Environment:**
- ECS Fargate: ~$60/month (2-4 tasks, 50% Spot)
- NAT Gateway: ~$64/month (multi-AZ)
- ALB: ~$16/month
- API Gateway: ~$3.50/1M requests
- **Total: ~$140-150/month + request costs**

## Monitoring

CloudWatch alarms are configured for:
- High CPU utilization (>80%)
- High memory utilization (>80%)
- ALB response time (>1s)
- Unhealthy targets
- 5XX errors

View metrics:
```bash
aws cloudwatch get-metric-statistics \
  --namespace AWS/ECS \
  --metric-name CPUUtilization \
  --dimensions Name=ClusterName,Value=$(terraform output -raw ecs_cluster_name) \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 300 \
  --statistics Average
```

## Cleanup

```bash
terraform destroy -auto-approve
```

## Troubleshooting

### Container fails to start

Check logs:
```bash
aws logs tail /ecs/mcp-agent-mcp --follow
```

### API Gateway returns 503

Check VPC Link status:
```bash
aws apigatewayv2 get-vpc-links
```

### High costs

- Enable Fargate Spot: Set `enable_fargate_spot = true`
- Reduce task count: Set `desired_count = 1`
- Use single NAT: Set `single_nat_gateway = true`

## Next Steps

1. **Add Authentication**: Integrate Cognito or API keys
2. **Add More Tools**: Extend MCP server with custom tools
3. **Add Resources**: Implement MCP resources for data access
4. **Add Prompts**: Implement MCP prompts for agent guidance
5. **CI/CD**: Automate deployments with GitHub Actions

## References

- [Model Context Protocol](https://modelcontextprotocol.io/)
- [MCP SDK Documentation](https://github.com/modelcontextprotocol/sdk)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | ../../modules/alb | n/a |
| <a name="module_api_gateway"></a> [api\_gateway](#module\_api\_gateway) | ../../modules/api-gateway | n/a |
| <a name="module_cloudwatch_alarms"></a> [cloudwatch\_alarms](#module\_cloudwatch\_alarms) | ../../modules/cloudwatch-alarms | n/a |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ../../modules/ecr | n/a |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | ../../modules/ecs | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.mcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_execution_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpc_link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.vpc_link_to_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name | `string` | `"mcp-agent"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | <pre>{<br/>  "Environment": "dev",<br/>  "ManagedBy": "terraform",<br/>  "Project": "mcp-agent-runtime"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | ALB DNS name (internal) |
| <a name="output_api_endpoint"></a> [api\_endpoint](#output\_api\_endpoint) | Agent Gateway API endpoint |
| <a name="output_ecr_repository_url"></a> [ecr\_repository\_url](#output\_ecr\_repository\_url) | ECR repository URL |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | ECS cluster name |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | ECS service name |
| <a name="output_test_commands"></a> [test\_commands](#output\_test\_commands) | Commands to test the MCP server |
<!-- END_TF_DOCS --><!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.18.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.33.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | ../../modules/alb | n/a |
| <a name="module_cloudwatch_alarms"></a> [cloudwatch\_alarms](#module\_cloudwatch\_alarms) | ../../modules/cloudwatch-alarms | n/a |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ../../modules/ecr | n/a |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | ../../modules/ecs | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_bedrockagentcore_gateway.mcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagentcore_gateway) | resource |
| [aws_bedrockagentcore_gateway_target.mcp_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bedrockagentcore_gateway_target) | resource |
| [aws_cloudwatch_log_group.mcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_execution_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name | `string` | `"mcp-agent"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | <pre>{<br/>  "Environment": "dev",<br/>  "ManagedBy": "terraform",<br/>  "Project": "mcp-agent-runtime"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | ALB DNS name (internal) |
| <a name="output_ecr_repository_url"></a> [ecr\_repository\_url](#output\_ecr\_repository\_url) | ECR repository URL |
| <a name="output_ecs_cluster_name"></a> [ecs\_cluster\_name](#output\_ecs\_cluster\_name) | ECS cluster name |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | ECS service name |
| <a name="output_gateway_id"></a> [gateway\_id](#output\_gateway\_id) | AgentCore Gateway ID |
| <a name="output_gateway_url"></a> [gateway\_url](#output\_gateway\_url) | AgentCore Gateway URL |
| <a name="output_test_commands"></a> [test\_commands](#output\_test\_commands) | Commands to test the MCP server |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
