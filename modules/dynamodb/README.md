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
