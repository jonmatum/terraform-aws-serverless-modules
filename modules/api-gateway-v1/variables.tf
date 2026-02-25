variable "name" {
  description = "Name prefix for API Gateway resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID for VPC Link"
  type        = string
}

variable "vpc_link_subnet_ids" {
  description = "Subnet IDs for VPC Link"
  type        = list(string)
}

variable "vpc_link_security_group_ids" {
  description = "Security group IDs for VPC Link"
  type        = list(string)
}

variable "stage_name" {
  description = "API Gateway stage name"
  type        = string
  default     = "prod"
}

variable "integrations" {
  description = "Map of API integrations"
  type = map(object({
    http_method   = string
    resource_path = string
    integration_uri = string
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
