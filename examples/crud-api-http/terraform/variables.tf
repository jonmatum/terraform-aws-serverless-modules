variable "project_name" {
  description = "Project name"
  type        = string
  default     = "crud-api-http"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "enable_waf" {
  description = "Enable WAF"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Project     = "crud-api-http"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
