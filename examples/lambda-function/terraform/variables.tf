variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "function_name" {
  description = "Name of the Lambda function"
  type        = string
  default     = "hello-lambda"
}

variable "image_tag" {
  description = "Docker image tag"
  type        = string
  default     = "latest"
}

variable "timeout" {
  description = "Function timeout in seconds"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Amount of memory in MB"
  type        = number
  default     = 512
}

variable "environment_variables" {
  description = "Environment variables for the Lambda function"
  type        = map(string)
  default = {
    ENVIRONMENT = "development"
    LOG_LEVEL   = "info"
  }
}

variable "enable_function_url" {
  description = "Enable Lambda function URL"
  type        = bool
  default     = true
}

variable "function_url_auth_type" {
  description = "Authorization type for function URL (AWS_IAM or NONE)"
  type        = string
  default     = "NONE"
}

variable "function_url_cors" {
  description = "CORS configuration for function URL"
  type        = any
  default = {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST"]
    allow_headers = ["content-type"]
    max_age       = 300
  }
}

variable "enable_xray" {
  description = "Enable AWS X-Ray tracing"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "development"
    Project     = "lambda-function"
    ManagedBy   = "terraform"
  }
}

# Production reliability features

variable "reserved_concurrent_executions" {
  description = "Reserved concurrent executions for the Lambda function (-1 for unreserved)"
  type        = number
  default     = -1
}

variable "enable_dlq" {
  description = "Enable Dead Letter Queue for failed invocations"
  type        = bool
  default     = false
}

variable "dlq_message_retention_seconds" {
  description = "Message retention period in DLQ (60-1209600 seconds)"
  type        = number
  default     = 1209600 # 14 days
}

variable "maximum_retry_attempts" {
  description = "Maximum retry attempts for async invocations (0-2)"
  type        = number
  default     = 2
}

variable "maximum_event_age_in_seconds" {
  description = "Maximum age of a request that Lambda sends to a function for processing (60-21600)"
  type        = number
  default     = 21600 # 6 hours
}

variable "enable_lambda_insights" {
  description = "Enable Lambda Insights for enhanced monitoring"
  type        = bool
  default     = false
}

# CloudWatch Alarms

variable "create_alarm_topic" {
  description = "Create SNS topic for alarm notifications"
  type        = bool
  default     = false
}

variable "alarm_email" {
  description = "Email address for alarm notifications (requires create_alarm_topic = true)"
  type        = string
  default     = null
}

variable "alarm_sns_topic_arn" {
  description = "SNS topic ARN for alarm notifications (optional, uses created topic if create_alarm_topic = true)"
  type        = string
  default     = null
}

variable "alarm_error_threshold" {
  description = "Threshold for error alarm"
  type        = number
  default     = 5
}

variable "alarm_throttle_threshold" {
  description = "Threshold for throttle alarm"
  type        = number
  default     = 5
}

variable "alarm_duration_threshold" {
  description = "Threshold for duration alarm in milliseconds"
  type        = number
  default     = 25000 # 25 seconds (below 30s timeout)
}

variable "alarm_concurrent_executions_threshold" {
  description = "Threshold for concurrent executions alarm"
  type        = number
  default     = 8 # 80% of reserved concurrency
}
