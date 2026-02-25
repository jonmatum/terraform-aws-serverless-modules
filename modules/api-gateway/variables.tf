variable "name" {
  description = "Name prefix for API Gateway resources"
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

variable "integrations" {
  description = "Map of route integrations"
  type = map(object({
    method          = string
    route_key       = string
    connection_type = string
    connection_id   = optional(string)
    uri             = string
  }))
  default = {}
}

variable "enable_throttling" {
  description = "Enable API Gateway throttling"
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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
