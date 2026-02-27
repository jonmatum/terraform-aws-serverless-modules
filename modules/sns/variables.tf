variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "display_name" {
  description = "Display name for the topic"
  type        = string
  default     = null
}

variable "fifo_topic" {
  description = "Whether this is a FIFO topic"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO topics"
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "delivery_policy" {
  description = "Delivery policy JSON"
  type        = string
  default     = null
}

variable "topic_policy" {
  description = "IAM policy for the topic"
  type        = string
  default     = null
}

variable "data_protection_policy" {
  description = "Data protection policy JSON"
  type        = string
  default     = null
}

variable "email_subscriptions" {
  description = "List of email addresses to subscribe"
  type        = list(string)
  default     = []
}

variable "sqs_subscriptions" {
  description = "List of SQS queue subscriptions"
  type = list(object({
    queue_arn            = string
    raw_message_delivery = optional(bool)
    filter_policy        = optional(string)
  }))
  default = []
}

variable "lambda_subscriptions" {
  description = "List of Lambda function subscriptions"
  type = list(object({
    function_arn  = string
    filter_policy = optional(string)
  }))
  default = []
}

variable "http_subscriptions" {
  description = "List of HTTP/HTTPS subscriptions"
  type = list(object({
    protocol      = string
    endpoint      = string
    filter_policy = optional(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
