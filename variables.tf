# Bucket
variable "bucket_name" {
  description = "S3 bucket name (globally unique, 3-63 chars, lowercase letters, numbers, and hyphens)"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be 3-63 characters, start and end with a letter or number, and contain only lowercase letters, numbers, hyphens, and dots."
  }
}

variable "tags" {
  description = "Map of tags applied to all resources"
  type        = map(string)
  default     = {}
}

# Storage
variable "force_destroy" {
  description = "Allow Terraform to delete non-empty buckets"
  type        = bool
  default     = false
}

variable "allow_public_access" {
  description = "Allow public access (false enforces S3 Block Public Access)"
  type        = bool
  default     = false
}

# CORS
variable "enable_cors" {
  description = "Enable CORS configuration"
  type        = bool
  default     = true
}

variable "cors_allowed_origins" {
  description = "List of allowed origins for CORS"
  type        = list(string)
  default     = ["*"]
}

variable "cors_max_age_seconds" {
  description = "Maximum age in seconds for CORS preflight responses"
  type        = number
  default     = 3600
}

# Lifecycle
variable "enable_object_lifecycle" {
  description = "Enable lifecycle management rules for cost optimization"
  type        = bool
  default     = true
}

variable "transition_to_ia_days" {
  description = "Days before transitioning objects to Standard-IA (0 disables)"
  type        = number
  default     = 30
}

variable "transition_to_glacier_days" {
  description = "Days before transitioning objects to Glacier Instant Retrieval (0 disables)"
  type        = number
  default     = 90
}

variable "expiration_days" {
  description = "Days before objects are deleted (0 disables)"
  type        = number
  default     = 0
}

# IAM
variable "create_iam_user" {
  description = "Create a dedicated IAM user with access key for S3 credentials"
  type        = bool
  default     = true
}

variable "iam_user_name" {
  description = "IAM user name when creating a new user"
  type        = string
  default     = "curator-s3-user"
}

variable "existing_iam_user_arn" {
  description = "ARN of an existing IAM user to grant bucket access (required when create_iam_user = false)"
  type        = string
  default     = ""
}
