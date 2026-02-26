variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "mcp-agent"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener (required for AgentCore Gateway Target)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "mcp-agent-runtime"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
