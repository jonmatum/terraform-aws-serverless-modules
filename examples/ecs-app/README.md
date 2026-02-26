# FastAPI ECS Example

Simple FastAPI application deployed to ECS with ALB.

## Architecture

See [detailed architecture documentation](./architecture.md) for comprehensive diagrams including:
- High-level architecture
- Terraform resource relationships
- Request flow sequences
- Auto-scaling behavior
- Monitoring setup
- Deployment flow
- Cost breakdown

## Features

- FastAPI web application
- ECS Fargate with auto-scaling (2-4 tasks)
- Application Load Balancer with optional HTTPS
- WAF protection with rate limiting and IP reputation rules
- CloudWatch alarms for monitoring
- Container Insights enabled
- ECR for container images
- CloudWatch logging
- Health checks

## Quick Start

```bash
cd examples/ecs-app
./deploy.sh
```

The script is idempotent and handles:
- Initial deployment (creates all infrastructure)
- Updates (rebuilds image, updates ECS service)

Optional: specify image tag
```bash
./deploy.sh v1.2.3
```

## Testing

```bash
# Get application URL
ALB_URL=$(cd terraform && terraform output -raw alb_dns_name)

# Test endpoints
curl http://$ALB_URL
curl http://$ALB_URL/health
```

## Configuration

### HTTPS (Optional)

To enable HTTPS, you need an ACM certificate:

1. Create or import a certificate in ACM
2. Create `terraform/terraform.tfvars`:

```hcl
enable_https    = true
certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/..."
```

This will:
- Enable HTTPS listener on port 443
- Redirect HTTP to HTTPS
- Use TLS 1.3 security policy

### WAF Protection (Optional)

WAF can be enabled for additional security:

```hcl
enable_waf = true
```

Features when enabled:
- Rate limiting (2000 requests per 5 min per IP)
- AWS managed IP reputation list
- Known bad inputs protection

Note: WAF logging requires additional Kinesis Firehose setup.

### Auto-scaling

Auto-scaling is enabled by default:
- Min tasks: 2
- Max tasks: 4
- CPU target: 70%
- Memory target: 80%

Customize in `terraform.tfvars`:
```hcl
autoscaling_min_capacity = 1
autoscaling_max_capacity = 10
```

### CloudWatch Alarms

Alarms are enabled by default for:
- High CPU utilization (>80%)
- High memory utilization (>80%)
- High response time (>1s)
- Unhealthy targets

Optional: Add SNS topic for notifications:
```hcl
alarm_sns_topic_arn = "arn:aws:sns:us-east-1:123456789012:alerts"
```

## Local Development

```bash
cd app
pip install -r requirements.txt
uvicorn app:app --reload
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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.33.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | ../../modules/alb | n/a |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ../../modules/ecr | n/a |
| <a name="module_ecs"></a> [ecs](#module\_ecs) | ../../modules/ecs | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_role.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecs_execution_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ecs_execution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_security_group.ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | Application name | `string` | `"my-app"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Port exposed by the container | `number` | `8000` | no |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | CPU units for the task | `string` | `"256"` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Desired number of tasks | `number` | `1` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables for the container | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_image_tag"></a> [image\_tag](#input\_image\_tag) | Docker image tag | `string` | `"latest"` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory for the task | `string` | `"512"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alb_dns_name"></a> [alb\_dns\_name](#output\_alb\_dns\_name) | DNS name of the ALB |
| <a name="output_aws_region"></a> [aws\_region](#output\_aws\_region) | AWS region |
| <a name="output_ecr_repository_url"></a> [ecr\_repository\_url](#output\_ecr\_repository\_url) | URL of the ECR repository |
| <a name="output_ecs_cluster_id"></a> [ecs\_cluster\_id](#output\_ecs\_cluster\_id) | ID of the ECS cluster |
| <a name="output_ecs_service_name"></a> [ecs\_service\_name](#output\_ecs\_service\_name) | Name of the ECS service |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | ID of the VPC |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
