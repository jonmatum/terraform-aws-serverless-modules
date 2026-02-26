terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

resource "aws_dynamodb_table" "this" {
  name           = var.table_name
  billing_mode   = var.billing_mode
  read_capacity  = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  hash_key       = var.hash_key
  range_key      = var.range_key

  attribute {
    name = var.hash_key
    type = var.hash_key_type
  }

  dynamic "attribute" {
    for_each = var.range_key != null ? [1] : []
    content {
      name = var.range_key
      type = var.range_key_type
    }
  }

  # Additional attributes for GSI
  dynamic "attribute" {
    for_each = var.global_secondary_indexes
    content {
      name = attribute.value.hash_key
      type = "S"
    }
  }

  dynamic "attribute" {
    for_each = [for gsi in var.global_secondary_indexes : gsi if gsi.range_key != null]
    content {
      name = attribute.value.range_key
      type = "S"
    }
  }

  # Global Secondary Indexes
  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      range_key       = global_secondary_index.value.range_key
      projection_type = global_secondary_index.value.projection_type
      read_capacity   = var.billing_mode == "PROVISIONED" ? global_secondary_index.value.read_capacity : null
      write_capacity  = var.billing_mode == "PROVISIONED" ? global_secondary_index.value.write_capacity : null
    }
  }

  # Point-in-time recovery
  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  # Encryption
  dynamic "server_side_encryption" {
    for_each = var.enable_encryption ? [1] : []
    content {
      enabled     = true
      kms_key_arn = var.kms_key_arn
    }
  }

  # Streams
  stream_enabled   = var.enable_streams
  stream_view_type = var.enable_streams ? var.stream_view_type : null

  # TTL
  dynamic "ttl" {
    for_each = var.ttl_enabled ? [1] : []
    content {
      enabled        = true
      attribute_name = var.ttl_attribute_name
    }
  }

  tags = var.tags
}

# Auto-scaling for read capacity
resource "aws_appautoscaling_target" "read" {
  count              = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? 1 : 0
  max_capacity       = var.autoscaling_read_max
  min_capacity       = var.autoscaling_read_min
  resource_id        = "table/${aws_dynamodb_table.this.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "read" {
  count              = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? 1 : 0
  name               = "${var.table_name}-read-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read[0].resource_id
  scalable_dimension = aws_appautoscaling_target.read[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.read[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = var.autoscaling_target_value
  }
}

# Auto-scaling for write capacity
resource "aws_appautoscaling_target" "write" {
  count              = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? 1 : 0
  max_capacity       = var.autoscaling_write_max
  min_capacity       = var.autoscaling_write_min
  resource_id        = "table/${aws_dynamodb_table.this.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "write" {
  count              = var.billing_mode == "PROVISIONED" && var.enable_autoscaling ? 1 : 0
  name               = "${var.table_name}-write-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write[0].resource_id
  scalable_dimension = aws_appautoscaling_target.write[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.write[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = var.autoscaling_target_value
  }
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "read_throttle" {
  alarm_name          = "${var.table_name}-read-throttle"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "ReadThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "DynamoDB read throttle events"

  dimensions = {
    TableName = aws_dynamodb_table.this.name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "write_throttle" {
  alarm_name          = "${var.table_name}-write-throttle"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "WriteThrottleEvents"
  namespace           = "AWS/DynamoDB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "DynamoDB write throttle events"

  dimensions = {
    TableName = aws_dynamodb_table.this.name
  }

  tags = var.tags
}
