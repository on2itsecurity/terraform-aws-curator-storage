# IAM User
locals {
  iam_user_arn = var.create_iam_user ? aws_iam_user.this[0].arn : var.existing_iam_user_arn
}

resource "aws_iam_user" "this" {
  count = var.create_iam_user ? 1 : 0
  name  = var.iam_user_name

  tags = var.tags
}

resource "aws_iam_access_key" "this" {
  count = var.create_iam_user ? 1 : 0
  user  = aws_iam_user.this[0].name
}

# S3 Bucket
resource "aws_s3_bucket" "this" {
  bucket        = var.bucket_name
  force_destroy = var.force_destroy

  tags = var.tags
}

# Disable object versioning - every file written by Curator is unique except
# the index file, and versioning prevents immediate re-creation of deleted objects
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Disabled"
  }
}

# Block Public Access
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = !var.allow_public_access
  block_public_policy     = !var.allow_public_access
  ignore_public_acls      = !var.allow_public_access
  restrict_public_buckets = !var.allow_public_access
}

# Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# CORS Configuration
resource "aws_s3_bucket_cors_configuration" "this" {
  count  = var.enable_cors ? 1 : 0
  bucket = aws_s3_bucket.this.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]
    allowed_origins = var.cors_allowed_origins
    max_age_seconds = var.cors_max_age_seconds
  }
}

# Lifecycle Rules
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  count = var.enable_object_lifecycle && anytrue([
    var.transition_to_ia_days > 0,
    var.transition_to_glacier_days > 0,
    var.expiration_days > 0,
  ]) ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    id     = "curator-lifecycle"
    status = "Enabled"

    filter {}

    # Transition to Standard-IA
    dynamic "transition" {
      for_each = var.transition_to_ia_days > 0 ? [1] : []
      content {
        days          = var.transition_to_ia_days
        storage_class = "STANDARD_IA"
      }
    }

    # Transition to Glacier Instant Retrieval
    dynamic "transition" {
      for_each = var.transition_to_glacier_days > 0 ? [1] : []
      content {
        days          = var.transition_to_glacier_days
        storage_class = "GLACIER_IR"
      }
    }

    # Object expiration
    dynamic "expiration" {
      for_each = var.expiration_days > 0 ? [1] : []
      content {
        days = var.expiration_days
      }
    }
  }
}

# Bucket Policy -- grant IAM user access
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CuratorAccess"
        Effect = "Allow"
        Principal = {
          AWS = local.iam_user_arn
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
        ]
        Resource = [
          aws_s3_bucket.this.arn,
          "${aws_s3_bucket.this.arn}/*",
        ]
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.this]
}
