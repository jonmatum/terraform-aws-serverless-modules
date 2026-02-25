variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "task_family" {
  description = "Task definition family name"
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_image" {
  description = "Docker image to run"
  type        = string
}

variable "container_port" {
  description = "Port exposed by the container"
  type        = number
}

variable "cpu" {
  description = "CPU units for the task"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Memory for the task"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 1
}

variable "execution_role_arn" {
  description = "ARN of the task execution role"
  type        = string
}

variable "task_role_arn" {
  description = "ARN of the task role"
  type        = string
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs"
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Assign public IP to tasks"
  type        = bool
  default     = false
}

variable "target_group_arn" {
  description = "ARN of the target group for load balancer"
  type        = string
  default     = null
}

variable "log_group_name" {
  description = "CloudWatch log group name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "secrets" {
  description = "Secrets from Secrets Manager or SSM Parameter Store"
  type = list(object({
    name      = string
    valueFrom = string
  }))
  default = []
}

variable "enable_autoscaling" {
  description = "Enable auto-scaling for the ECS service"
  type        = bool
  default     = true
}

variable "autoscaling_min_capacity" {
  description = "Minimum number of tasks"
  type        = number
  default     = 1
}

variable "autoscaling_max_capacity" {
  description = "Maximum number of tasks"
  type        = number
  default     = 4
}

variable "autoscaling_cpu_target" {
  description = "Target CPU utilization percentage for auto-scaling"
  type        = number
  default     = 70
}

variable "autoscaling_memory_target" {
  description = "Target memory utilization percentage for auto-scaling"
  type        = number
  default     = 80
}

variable "enable_container_insights" {
  description = "Enable Container Insights for the ECS cluster"
  type        = bool
  default     = true
}

variable "health_check_grace_period_seconds" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 60
}

variable "enable_fargate_spot" {
  description = "Enable Fargate Spot capacity provider"
  type        = bool
  default     = false
}

variable "fargate_spot_weight" {
  description = "Weight for Fargate Spot in capacity provider strategy (0-100)"
  type        = number
  default     = 50
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
