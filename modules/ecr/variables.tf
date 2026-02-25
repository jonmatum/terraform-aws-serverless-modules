variable "repository_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "image_tag_mutability" {
  description = "Tag mutability setting for the repository"
  type        = string
  default     = "MUTABLE"
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "Force delete repository even if it contains images"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for the repository (AES256 or KMS)"
  type        = string
  default     = "AES256"
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption (required if encryption_type is KMS)"
  type        = string
  default     = null
}

variable "enable_lifecycle_policy" {
  description = "Enable default lifecycle policy to keep last 10 images"
  type        = bool
  default     = true
}

variable "lifecycle_policy" {
  description = "Custom ECR lifecycle policy JSON (overrides default)"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the repository"
  type        = map(string)
  default     = {}
}
