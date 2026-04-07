output "storage_url" {
  description = "S3 endpoint hostname for the bucket region"
  value       = "s3.${aws_s3_bucket.this.region}.amazonaws.com"
}

output "access_key_id" {
  description = "IAM access key ID for S3 authentication"
  value       = var.create_iam_user ? aws_iam_access_key.this[0].id : ""
}

output "secret_access_key" {
  description = "IAM secret access key (sensitive)"
  value       = var.create_iam_user ? aws_iam_access_key.this[0].secret : ""
  sensitive   = true
}

output "bucket" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.this.bucket
}

output "region" {
  description = "S3 bucket region"
  value       = aws_s3_bucket.this.region
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.this.arn
}

output "iam_user_arn" {
  description = "ARN of the IAM user with bucket access"
  value       = local.iam_user_arn
}
