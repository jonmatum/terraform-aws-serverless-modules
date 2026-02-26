# Multi-Service API Gateway Example

FastAPI and Node MCP services behind API Gateway with VPC Link.

## Architecture

See [detailed architecture documentation](https://github.com/jonmatum/terraform-aws-serverless-modules/tree/main/examples/api-gateway-multi-service/architecture.md) for comprehensive diagrams including:
- High-level architecture
- API Gateway routing
- Terraform resource relationships
- Request flow sequences
- Service isolation
- Deployment strategies
- Cost breakdown

## Features

- FastAPI service on ECS (port 8000) → `/api/fastapi/*`
- Node MCP service on ECS (port 3000) → `/api/mcp/*`
- API Gateway HTTP API with VPC Link to private ECS services
- Services in private subnets, exposed via API Gateway
- Independent scaling per service

## Deployment

### Initial Deployment

```bash
./deploy.sh
```

### Redeploy with Specific Tag

```bash
./deploy.sh v1.2.3
```

### CI/CD Usage

```bash
# In GitHub Actions or other CI/CD
export AWS_REGION=us-east-1
./deploy.sh $GITHUB_SHA
```

## Testing

```bash
# Get API endpoint
API_ENDPOINT=$(cd terraform && terraform output -raw api_endpoint)

# Test FastAPI
curl $API_ENDPOINT/api/fastapi

# Test MCP
curl $API_ENDPOINT/api/mcp
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.34.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb_fastapi"></a> [alb\_fastapi](#module\_alb\_fastapi) | ../../modules/alb | n/a |
| <a name="module_alb_mcp"></a> [alb\_mcp](#module\_alb\_mcp) | ../../modules/alb | n/a |
| <a name="module_api_gateway"></a> [api\_gateway](#module\_api\_gateway) | ../../modules/api-gateway | n/a |
| <a name="module_ecr_fastapi"></a> [ecr\_fastapi](#module\_ecr\_fastapi) | ../../modules/ecr | n/a |
| <a name="module_ecr_mcp"></a> [ecr\_mcp](#module\_ecr\_mcp) | ../../modules/ecr | n/a |
| <a name="module_ecs_fastapi"></a> [ecs\_fastapi](#module\_ecs\_fastapi) | ../../modules/ecs | n/a |
| <a name="module_ecs_mcp"></a> [ecs\_mcp](#module\_ecs\_mcp) | ../../modules/ecs | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.fastapi](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.mcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_execution_custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpc_link](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.vpc_link_to_fastapi_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.vpc_link_to_mcp_alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name | `string` | `"multi-service"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | <pre>{<br/>  "Environment": "dev",<br/>  "ManagedBy": "terraform",<br/>  "Project": "multi-service"<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_endpoint"></a> [api\_endpoint](#output\_api\_endpoint) | API Gateway endpoint |
| <a name="output_ecs_fastapi_cluster_id"></a> [ecs\_fastapi\_cluster\_id](#output\_ecs\_fastapi\_cluster\_id) | FastAPI ECS cluster ID |
| <a name="output_ecs_fastapi_cluster_name"></a> [ecs\_fastapi\_cluster\_name](#output\_ecs\_fastapi\_cluster\_name) | FastAPI ECS cluster name |
| <a name="output_ecs_mcp_cluster_id"></a> [ecs\_mcp\_cluster\_id](#output\_ecs\_mcp\_cluster\_id) | MCP ECS cluster ID |
| <a name="output_ecs_mcp_cluster_name"></a> [ecs\_mcp\_cluster\_name](#output\_ecs\_mcp\_cluster\_name) | MCP ECS cluster name |
| <a name="output_fastapi_ecr_url"></a> [fastapi\_ecr\_url](#output\_fastapi\_ecr\_url) | FastAPI ECR repository URL |
| <a name="output_mcp_ecr_url"></a> [mcp\_ecr\_url](#output\_mcp\_ecr\_url) | MCP ECR repository URL |
| <a name="output_test_commands"></a> [test\_commands](#output\_test\_commands) | Commands to test the services |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
