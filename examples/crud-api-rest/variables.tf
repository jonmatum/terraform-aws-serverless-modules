variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "crud-api-rest"
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
    Environment = "dev"
    Project     = "crud-api-rest"
    ManagedBy   = "terraform"
  }
}
