variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "sqs-example"
}

variable "environment" {
  description = "Environment"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default = {
    Project     = "sqs-example"
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}
