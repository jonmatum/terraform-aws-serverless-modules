terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# ECS Service CPU Alarm
resource "aws_cloudwatch_metric_alarm" "ecs_cpu_high" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.service_name}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "ECS service CPU utilization is too high"
  alarm_actions       = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  tags = var.tags
}

# ECS Service Memory Alarm
resource "aws_cloudwatch_metric_alarm" "ecs_memory_high" {
  count               = var.enable_alarms ? 1 : 0
  alarm_name          = "${var.service_name}-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = var.memory_threshold
  alarm_description   = "ECS service memory utilization is too high"
  alarm_actions       = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = var.service_name
  }

  tags = var.tags
}

# ALB Target Response Time Alarm
resource "aws_cloudwatch_metric_alarm" "alb_target_response_time" {
  count               = var.enable_alarms && var.target_group_arn_suffix != null ? 1 : 0
  alarm_name          = "${var.service_name}-response-time-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Average"
  threshold           = var.target_response_time
  alarm_description   = "ALB target response time is too high"
  alarm_actions       = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  dimensions = {
    TargetGroup = var.target_group_arn_suffix
  }

  tags = var.tags
}

# ALB Unhealthy Host Count Alarm
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_hosts" {
  count               = var.enable_alarms && var.target_group_arn_suffix != null ? 1 : 0
  alarm_name          = "${var.service_name}-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "ALB has unhealthy targets"
  alarm_actions       = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  dimensions = {
    TargetGroup = var.target_group_arn_suffix
  }

  tags = var.tags
}

# ALB 5XX Error Rate Alarm
resource "aws_cloudwatch_metric_alarm" "alb_5xx_errors" {
  count               = var.enable_alarms && var.alb_arn_suffix != null ? 1 : 0
  alarm_name          = "${var.service_name}-5xx-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "ALB is receiving too many 5XX errors"
  alarm_actions       = var.sns_topic_arn != null ? [var.sns_topic_arn] : []

  dimensions = {
    LoadBalancer = var.alb_arn_suffix
  }

  tags = var.tags
}
