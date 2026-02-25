variable "name" {
  description = "Name prefix for API Gateway resources"
  type        = string
}

variable "vpc_link_subnet_ids" {
  description = "Subnet IDs for VPC Link"
  type        = list(string)
}

variable "vpc_link_security_group_ids" {
  description = "Security group IDs for VPC Link (optional)"
  type        = list(string)
  default     = []
}

variable "alb_listener_arn" {
  description = "ARN of the ALB listener for VPC Link integration (optional, for OpenAPI mode)"
  type        = string
  default     = null
}

variable "openapi_spec" {
  description = "OpenAPI/Swagger specification (JSON string). If provided, uses OpenAPI mode instead of integrations."
  type        = string
  default     = null
}

variable "integrations" {
  description = "Map of integrations (legacy mode, ignored if openapi_spec is provided)"
  type = map(object({
    http_method     = string
    integration_uri = string
  }))
  default = {}
}

variable "stage_name" {
  description = "Stage name"
  type        = string
  default     = "prod"
}

variable "enable_access_logs" {
  description = "Enable API Gateway access logs"
  type        = bool
  default     = true
}

variable "enable_xray_tracing" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = true
}

variable "throttle_burst_limit" {
  description = "Throttle burst limit"
  type        = number
  default     = 5000
}

variable "throttle_rate_limit" {
  description = "Throttle rate limit (requests per second)"
  type        = number
  default     = 10000
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
