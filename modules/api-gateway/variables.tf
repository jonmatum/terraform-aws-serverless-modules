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

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
