output "bucket" {
  description = "S3 bucket name"
  value       = module.curator_storage.bucket
}

output "storage_url" {
  description = "S3 endpoint hostname"
  value       = module.curator_storage.storage_url
}
