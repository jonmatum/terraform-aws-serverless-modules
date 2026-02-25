# Terraform AWS DynamoDB Module

DynamoDB table module with configurable capacity and indexes.

## Usage

```hcl
module "dynamodb" {
  source = "github.com/jonmatum/aws-ecs-poc//modules/dynamodb?ref=modules/dynamodb/v0.1.0"

  table_name     = "my-table"
  hash_key       = "id"
  billing_mode   = "PAY_PER_REQUEST"

  attributes = [
    {
      name = "id"
      type = "S"
    }
  ]

  tags = {
    Environment = "production"
  }
}
```

## Features

- DynamoDB table with configurable capacity
- Support for hash and range keys
- Global and local secondary indexes
- Point-in-time recovery
- Server-side encryption
- TTL support

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| table_name | Name of the DynamoDB table | string | - | yes |
| hash_key | Hash key attribute name | string | - | yes |
| range_key | Range key attribute name | string | null | no |
| billing_mode | Billing mode (PROVISIONED or PAY_PER_REQUEST) | string | "PAY_PER_REQUEST" | no |
| attributes | List of attribute definitions | list(object) | - | yes |
| tags | Tags to apply to resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| table_id | ID of the DynamoDB table |
| table_arn | ARN of the DynamoDB table |
| table_name | Name of the DynamoDB table |
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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appautoscaling_policy.read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_policy.write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_policy) | resource |
| [aws_appautoscaling_target.read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_appautoscaling_target.write](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_cloudwatch_metric_alarm.read_throttle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.write_throttle](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_dynamodb_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_autoscaling_read_max"></a> [autoscaling\_read\_max](#input\_autoscaling\_read\_max) | Maximum read capacity for auto-scaling | `number` | `100` | no |
| <a name="input_autoscaling_read_min"></a> [autoscaling\_read\_min](#input\_autoscaling\_read\_min) | Minimum read capacity for auto-scaling | `number` | `5` | no |
| <a name="input_autoscaling_target_value"></a> [autoscaling\_target\_value](#input\_autoscaling\_target\_value) | Target utilization percentage for auto-scaling | `number` | `70` | no |
| <a name="input_autoscaling_write_max"></a> [autoscaling\_write\_max](#input\_autoscaling\_write\_max) | Maximum write capacity for auto-scaling | `number` | `100` | no |
| <a name="input_autoscaling_write_min"></a> [autoscaling\_write\_min](#input\_autoscaling\_write\_min) | Minimum write capacity for auto-scaling | `number` | `5` | no |
| <a name="input_billing_mode"></a> [billing\_mode](#input\_billing\_mode) | Billing mode (PROVISIONED or PAY\_PER\_REQUEST) | `string` | `"PAY_PER_REQUEST"` | no |
| <a name="input_enable_autoscaling"></a> [enable\_autoscaling](#input\_enable\_autoscaling) | Enable auto-scaling for PROVISIONED mode | `bool` | `false` | no |
| <a name="input_enable_encryption"></a> [enable\_encryption](#input\_enable\_encryption) | Enable encryption at rest | `bool` | `true` | no |
| <a name="input_enable_point_in_time_recovery"></a> [enable\_point\_in\_time\_recovery](#input\_enable\_point\_in\_time\_recovery) | Enable point-in-time recovery | `bool` | `true` | no |
| <a name="input_enable_streams"></a> [enable\_streams](#input\_enable\_streams) | Enable DynamoDB Streams | `bool` | `false` | no |
| <a name="input_global_secondary_indexes"></a> [global\_secondary\_indexes](#input\_global\_secondary\_indexes) | List of global secondary indexes | <pre>list(object({<br/>    name            = string<br/>    hash_key        = string<br/>    range_key       = optional(string)<br/>    projection_type = string<br/>    read_capacity   = optional(number)<br/>    write_capacity  = optional(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_hash_key"></a> [hash\_key](#input\_hash\_key) | Hash key (partition key) for the table | `string` | `"id"` | no |
| <a name="input_hash_key_type"></a> [hash\_key\_type](#input\_hash\_key\_type) | Hash key type (S, N, or B) | `string` | `"S"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | KMS key ARN for encryption (uses AWS managed key if not provided) | `string` | `null` | no |
| <a name="input_range_key"></a> [range\_key](#input\_range\_key) | Range key (sort key) for the table | `string` | `null` | no |
| <a name="input_range_key_type"></a> [range\_key\_type](#input\_range\_key\_type) | Range key type (S, N, or B) | `string` | `"S"` | no |
| <a name="input_read_capacity"></a> [read\_capacity](#input\_read\_capacity) | Read capacity units (only for PROVISIONED mode) | `number` | `5` | no |
| <a name="input_stream_view_type"></a> [stream\_view\_type](#input\_stream\_view\_type) | Stream view type (KEYS\_ONLY, NEW\_IMAGE, OLD\_IMAGE, NEW\_AND\_OLD\_IMAGES) | `string` | `"NEW_AND_OLD_IMAGES"` | no |
| <a name="input_table_name"></a> [table\_name](#input\_table\_name) | Name of the DynamoDB table | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_ttl_attribute_name"></a> [ttl\_attribute\_name](#input\_ttl\_attribute\_name) | TTL attribute name | `string` | `"ttl"` | no |
| <a name="input_ttl_enabled"></a> [ttl\_enabled](#input\_ttl\_enabled) | Enable TTL | `bool` | `false` | no |
| <a name="input_write_capacity"></a> [write\_capacity](#input\_write\_capacity) | Write capacity units (only for PROVISIONED mode) | `number` | `5` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_stream_arn"></a> [stream\_arn](#output\_stream\_arn) | ARN of the DynamoDB stream |
| <a name="output_stream_label"></a> [stream\_label](#output\_stream\_label) | Label of the DynamoDB stream |
| <a name="output_table_arn"></a> [table\_arn](#output\_table\_arn) | ARN of the DynamoDB table |
| <a name="output_table_id"></a> [table\_id](#output\_table\_id) | ID of the DynamoDB table |
| <a name="output_table_name"></a> [table\_name](#output\_table\_name) | Name of the DynamoDB table |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
