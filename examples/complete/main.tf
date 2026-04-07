terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "curator_storage" {
  source  = "on2itsecurity/curator-storage/aws"
  version = "~> 1.0"

  bucket_name = var.bucket_name

  # Storage
  force_destroy = false

  # Access
  allow_public_access = false

  # CORS
  enable_cors          = true
  cors_allowed_origins = ["*"]
  cors_max_age_seconds = 3600

  # Lifecycle management
  enable_object_lifecycle    = true
  transition_to_ia_days      = 30
  transition_to_glacier_days = 90
  expiration_days            = 365

  # IAM user
  create_iam_user = true
  iam_user_name   = "curator-s3-user"

  tags = var.tags
}
