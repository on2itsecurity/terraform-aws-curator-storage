# AUXO Curator - AWS S3 Storage Module

Terraform/OpenTofu module for deploying Amazon S3 storage for AUXO Curator log ingestion. This module creates an S3 bucket with configurable lifecycle policies, a dedicated IAM user, and S3-compatible access credentials.

## Prerequisites

- AWS account with appropriate permissions
- Authenticated AWS CLI (`aws configure` or environment credentials)
- Terraform >= 1.6.0 or OpenTofu >= 1.6.0

## Usage

```hcl
module "curator_storage" {
  source  = "on2itsecurity/curator-storage/aws"
  version = "~> 1.0"

  bucket_name = "mycompany-curator-logs"
}
```

## Requirements

| Name                 | Version  |
| -------------------- | -------- |
| terraform / opentofu | >= 1.6.0 |
| aws                  | >= 5.0.0 |

## Inputs

| Name                       | Description                                                                  | Type           | Default            | Required |
| -------------------------- | ---------------------------------------------------------------------------- | -------------- | ------------------ | -------- |
| bucket_name                | S3 bucket name (globally unique, 3-63 chars, lowercase alphanumeric)         | `string`       | n/a                | **yes**  |
| tags                       | Map of tags applied to all resources                                         | `map(string)`  | `{}`               | no       |
| force_destroy              | Allow Terraform to delete non-empty buckets                                  | `bool`         | `false`            | no       |
| allow_public_access        | Allow public access (false enforces S3 Block Public Access)                  | `bool`         | `false`            | no       |
| enable_cors                | Enable CORS configuration                                                    | `bool`         | `true`             | no       |
| cors_allowed_origins       | List of allowed origins for CORS                                             | `list(string)` | `["*"]`            | no       |
| cors_max_age_seconds       | Maximum age in seconds for CORS preflight responses                          | `number`       | `3600`             | no       |
| enable_object_lifecycle    | Enable lifecycle management rules                                            | `bool`         | `true`             | no       |
| transition_to_ia_days      | Days before transitioning to Standard-IA (0 disables)                        | `number`       | `30`               | no       |
| transition_to_glacier_days | Days before transitioning to Glacier Instant Retrieval (0 disables)          | `number`       | `90`               | no       |
| expiration_days            | Days before objects are deleted (0 disables)                                 | `number`       | `0`                | no       |
| create_iam_user            | Create a dedicated IAM user with access key for S3 credentials               | `bool`         | `true`             | no       |
| iam_user_name              | IAM user name when creating a new user                                       | `string`       | `"curator-s3-user"`| no       |
| existing_iam_user_arn      | ARN of an existing IAM user (when create_iam_user = false)                   | `string`       | `""`               | no       |

## Outputs

| Name              | Description                                     |
| ----------------- | ----------------------------------------------- |
| storage_url       | S3 endpoint hostname for the bucket region       |
| access_key_id     | IAM access key ID for S3 authentication          |
| secret_access_key | IAM secret access key (sensitive)                |
| bucket            | S3 bucket name                                   |
| region            | S3 bucket region                                 |
| bucket_arn        | ARN of the S3 bucket                             |
| iam_user_arn      | ARN of the IAM user with bucket access           |

## Lifecycle Management

By default, the module enables cost-optimization lifecycle rules:

| Tier                      | After Days   | Cost Impact                     |
| ------------------------- | ------------ | ------------------------------- |
| Standard-IA               | 30           | ~45% cheaper storage            |
| Glacier Instant Retrieval | 90           | ~68% cheaper storage            |
| Delete                    | disabled (0) | Set `expiration_days` to enable |

## Design Decisions

- **Object versioning is disabled.** Every file written by Curator is unique except the index file. Versioning prevents immediate re-creation of deleted objects, which causes problems for the solution.
- **Server-side encryption** is enabled by default using Amazon S3-managed keys (SSE-S3, AES256).
- **Block Public Access** is enforced by default, matching the security posture of the Azure and GCP storage modules.

## Examples

- [Basic](https://github.com/on2itsecurity/terraform-aws-curator-storage/tree/main/examples/basic) - Minimal deployment with required variables only
- [Complete](https://github.com/on2itsecurity/terraform-aws-curator-storage/tree/main/examples/complete) - Full deployment with lifecycle, CORS, and IAM options

## License

MIT
