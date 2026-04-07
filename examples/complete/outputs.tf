output "bucket" {
  description = "S3 bucket name"
  value       = module.curator_storage.bucket
}

output "storage_url" {
  description = "S3 endpoint hostname"
  value       = module.curator_storage.storage_url
}

output "access_key_id" {
  description = "IAM access key ID"
  value       = module.curator_storage.access_key_id
}

output "region" {
  description = "S3 bucket region"
  value       = module.curator_storage.region
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.curator_storage.bucket_arn
}

output "iam_user_arn" {
  description = "ARN of the IAM user with bucket access"
  value       = module.curator_storage.iam_user_arn
}
