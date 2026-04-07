variable "region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-west-1"
}

variable "bucket_name" {
  description = "S3 bucket name (globally unique)"
  type        = string
}

variable "tags" {
  description = "Map of tags applied to all resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
  }
}
