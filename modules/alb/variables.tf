variable "name" {
  description = "Name prefix for ALB resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ALB"
  type        = list(string)
}

variable "internal" {
  description = "Whether ALB is internal"
  type        = bool
  default     = false
}

variable "target_port" {
  description = "Port for target group"
  type        = number
}

variable "health_check_path" {
  description = "Health check path"
  type        = string
  default     = "/"
}

variable "listener_port" {
  description = "Port for the listener"
  type        = number
  default     = 80
}

variable "deregistration_delay" {
  description = "Time in seconds for connection draining"
  type        = number
  default     = 30
}

variable "enable_access_logs" {
  description = "Enable ALB access logs"
  type        = bool
  default     = true
}

variable "access_logs_bucket" {
  description = "S3 bucket name for ALB access logs (created if not provided)"
  type        = string
  default     = null
}

variable "enable_https" {
  description = "Enable HTTPS listener"
  type        = bool
  default     = false
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
  default     = null
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listener"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "redirect_http_to_https" {
  description = "Redirect HTTP traffic to HTTPS"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
