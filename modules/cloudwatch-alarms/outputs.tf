output "cpu_alarm_arn" {
  description = "ARN of the CPU utilization alarm"
  value       = var.enable_alarms ? aws_cloudwatch_metric_alarm.ecs_cpu_high[0].arn : null
}

output "memory_alarm_arn" {
  description = "ARN of the memory utilization alarm"
  value       = var.enable_alarms ? aws_cloudwatch_metric_alarm.ecs_memory_high[0].arn : null
}
