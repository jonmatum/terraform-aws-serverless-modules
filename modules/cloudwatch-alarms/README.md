# Terraform AWS CloudWatch Alarms Module

CloudWatch alarms module for monitoring AWS resources.

## Usage

```hcl
module "cloudwatch_alarms" {
  source = "github.com/jonmatum/aws-ecs-poc//modules/cloudwatch-alarms?ref=modules/cloudwatch-alarms/v0.1.0"

  # Add your configuration here
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
| [aws_cloudwatch_metric_alarm.alb_5xx_errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.alb_target_response_time](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.alb_unhealthy_hosts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.ecs_cpu_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.ecs_memory_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_arn_suffix"></a> [alb\_arn\_suffix](#input\_alb\_arn\_suffix) | ALB ARN suffix for metrics | `string` | `null` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | ECS cluster name | `string` | n/a | yes |
| <a name="input_cpu_threshold"></a> [cpu\_threshold](#input\_cpu\_threshold) | CPU utilization threshold percentage | `number` | `80` | no |
| <a name="input_enable_alarms"></a> [enable\_alarms](#input\_enable\_alarms) | Enable CloudWatch alarms | `bool` | `true` | no |
| <a name="input_memory_threshold"></a> [memory\_threshold](#input\_memory\_threshold) | Memory utilization threshold percentage | `number` | `80` | no |
| <a name="input_service_name"></a> [service\_name](#input\_service\_name) | ECS service name | `string` | n/a | yes |
| <a name="input_sns_topic_arn"></a> [sns\_topic\_arn](#input\_sns\_topic\_arn) | SNS topic ARN for alarm notifications | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_target_group_arn_suffix"></a> [target\_group\_arn\_suffix](#input\_target\_group\_arn\_suffix) | Target group ARN suffix for metrics | `string` | `null` | no |
| <a name="input_target_response_time"></a> [target\_response\_time](#input\_target\_response\_time) | Target response time in seconds | `number` | `1` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cpu_alarm_arn"></a> [cpu\_alarm\_arn](#output\_cpu\_alarm\_arn) | ARN of the CPU utilization alarm |
| <a name="output_memory_alarm_arn"></a> [memory\_alarm\_arn](#output\_memory\_alarm\_arn) | ARN of the memory utilization alarm |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
