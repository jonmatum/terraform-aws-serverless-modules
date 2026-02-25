variable "name" {
  description = "Name for the WAF Web ACL"
  type        = string
}

variable "scope" {
  description = "Scope of the WAF (REGIONAL for ALB/API Gateway, CLOUDFRONT for CloudFront)"
  type        = string
  default     = "REGIONAL"
}

variable "resource_arn" {
  description = "ARN of the resource to associate with WAF (ALB or API Gateway)"
  type        = string
  default     = null
}

variable "enable_rate_limiting" {
  description = "Enable rate limiting rule"
  type        = bool
  default     = true
}

variable "rate_limit" {
  description = "Rate limit per 5 minutes per IP"
  type        = number
  default     = 2000
}

variable "enable_geo_blocking" {
  description = "Enable geographic blocking"
  type        = bool
  default     = false
}

variable "blocked_countries" {
  description = "List of country codes to block (e.g., ['CN', 'RU'])"
  type        = list(string)
  default     = []
}

variable "enable_ip_reputation" {
  description = "Enable AWS managed IP reputation list"
  type        = bool
  default     = true
}

variable "enable_known_bad_inputs" {
  description = "Enable AWS managed known bad inputs rule"
  type        = bool
  default     = true
}

variable "allowed_ip_addresses" {
  description = "List of allowed IP addresses/CIDR blocks"
  type        = list(string)
  default     = []
}

variable "blocked_ip_addresses" {
  description = "List of blocked IP addresses/CIDR blocks"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
