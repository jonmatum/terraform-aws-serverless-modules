variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "agentcore-full"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS (required for ECS Gateway Target)"
  type        = string
  default     = ""
}

variable "enable_dlq" {
  description = "Enable Dead Letter Queue for Lambda functions"
  type        = bool
  default     = false
}

variable "create_alarm_topic" {
  description = "Create SNS topic for alarm notifications"
  type        = bool
  default     = false
}

variable "alarm_email" {
  description = "Email address for alarm notifications"
  type        = string
  default     = null
}

variable "alarm_sns_topic_arn" {
  description = "Existing SNS topic ARN for alarms (optional)"
  type        = string
  default     = null
}

variable "enable_vpc_flow_logs" {
  description = "Enable VPC Flow Logs for security monitoring"
  type        = bool
  default     = false
}

variable "enable_xray" {
  description = "Enable X-Ray tracing for Lambda functions"
  type        = bool
  default     = false
}

variable "agent_model" {
  description = "Bedrock foundation model for agent"
  type        = string
  default     = "anthropic.claude-3-sonnet-20240229-v1:0"
}

variable "agent_instruction" {
  description = "Instructions for the Bedrock agent"
  type        = string
  default     = <<-EOT
    You are a helpful AI assistant with access to company documentation and external APIs.
    
    You can:
    - Search company documentation to answer questions
    - Get weather information for any location
    - Query databases for information
    
    Always be helpful, accurate, and cite your sources when using the knowledge base.
    If you don't know something, say so rather than making up information.
  EOT
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "agentcore-full"
    ManagedBy   = "terraform"
    Environment = "dev"
  }
}
