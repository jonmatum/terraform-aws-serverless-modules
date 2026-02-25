# Terraform AWS ECS Fargate Module

ECS Fargate service module with cluster, task definition, and service.

## Usage

```hcl
module "ecs" {
  source = "github.com/jonmatum/aws-ecs-poc//modules/ecs?ref=modules/ecs/v0.1.0"

  cluster_name       = "my-cluster"
  task_family        = "my-app"
  service_name       = "my-service"
  container_name     = "app"
  container_image    = "123456789.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
  container_port     = 8000
  execution_role_arn = aws_iam_role.ecs_execution.arn
  subnet_ids         = ["subnet-xxxxx", "subnet-yyyyy"]
  security_group_ids = ["sg-xxxxx"]
  log_group_name     = "/ecs/my-app"
  aws_region         = "us-east-1"
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.33.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.ecs_cpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.ecs_memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_ecs_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_cluster_capacity_providers.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster_capacity_providers) | resource |
| [aws_ecs_service.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Assign public IP to tasks | `bool` | `false` | no |
| <a name="input_autoscaling_cpu_target"></a> [autoscaling\_cpu\_target](#input\_autoscaling\_cpu\_target) | Target CPU utilization percentage for auto-scaling | `number` | `70` | no |
| <a name="input_autoscaling_max_capacity"></a> [autoscaling\_max\_capacity](#input\_autoscaling\_max\_capacity) | Maximum number of tasks | `number` | `4` | no |
| <a name="input_autoscaling_memory_target"></a> [autoscaling\_memory\_target](#input\_autoscaling\_memory\_target) | Target memory utilization percentage for auto-scaling | `number` | `80` | no |
| <a name="input_autoscaling_min_capacity"></a> [autoscaling\_min\_capacity](#input\_autoscaling\_min\_capacity) | Minimum number of tasks | `number` | `1` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Name of the ECS cluster | `string` | n/a | yes |
| <a name="input_container_image"></a> [container\_image](#input\_container\_image) | Docker image to run | `string` | n/a | yes |
| <a name="input_container_name"></a> [container\_name](#input\_container\_name) | Name of the container | `string` | n/a | yes |
| <a name="input_container_port"></a> [container\_port](#input\_container\_port) | Port exposed by the container | `number` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | CPU units for the task | `string` | `"256"` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | Desired number of tasks | `number` | `1` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Enable auto-scaling for the ECS service | `bool` | `true` | no |
| <a name="input_enable_container_insights"></a> [enable\_container\_insights](#input\_enable\_container\_insights) | Enable Container Insights for the ECS cluster | `bool` | `true` | no |
| <a name="input_enable_fargate_spot"></a> [enable\_fargate\_spot](#input\_enable\_fargate\_spot) | Enable Fargate Spot capacity provider | `bool` | `false` | no |
| <a name="input_environment_variables"></a> [environment\_variables](#input\_environment\_variables) | Environment variables for the container | <pre>list(object({<br/>    name  = string<br/>    value = string<br/>  }))</pre> | `[]` | no |
| <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn) | ARN of the task execution role | `string` | n/a | yes |
| <a name="input_fargate_spot_weight"></a> [fargate\_spot\_weight](#input\_fargate\_spot\_weight) | Weight for Fargate Spot in capacity provider strategy (0-100) | `number` | `50` | no |
| <a name="input_health_check_grace_period_seconds"></a> [health\_check\_grace\_period\_seconds](#input\_health\_check\_grace\_period\_seconds) | Health check grace period in seconds | `number` | `60` | no |
| <a name="input_log_group_name"></a> [log\_group\_name](#input\_log\_group\_name) | CloudWatch log group name | `string` | n/a | yes |
| <a name="input_memory"></a> [memory](#input\_memory) | Memory for the task | `string` | `"512"` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Secrets from Secrets Manager or SSM Parameter Store | <pre>list(object({<br/>    name      = string<br/>    valueFrom = string<br/>  }))</pre> | `[]` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs | `list(string)` | n/a | yes |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | Name of the ECS service | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_target_group_arn"></a> [target\_group\_arn](#input\_target\_group\_arn) | ARN of the target group for load balancer | `string` | `null` | no |
| <a name="input_task_family"></a> [task\_family](#input\_task\_family) | Task definition family name | `string` | n/a | yes |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | ARN of the task role | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_arn"></a> [cluster\_arn](#output\_cluster\_arn) | ARN of the ECS cluster |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | ID of the ECS cluster |
| <a name="output_service_id"></a> [service\_id](#output\_service\_id) | ID of the ECS service |
| <a name="output_service_name"></a> [service\_name](#output\_service\_name) | Name of the ECS service |
| <a name="output_task_definition_arn"></a> [task\_definition\_arn](#output\_task\_definition\_arn) | ARN of the task definition |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
