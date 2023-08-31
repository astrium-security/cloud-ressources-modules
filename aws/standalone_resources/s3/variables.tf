variable "prefix" {
  description = "The prefix for the S3 bucket name"
  type        = string
}

variable "app_environment" {
  description = "The environment (e.g., prod, dev, staging) for which the S3 bucket is being created"
  type        = string
}

variable "name" {
  description = "A name to be appended to the S3 bucket name"
  type        = string
}

variable "cloudtrail_bucket_name" {
  description = "cloudtrail_bucket_name"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key to be used for server-side encryption"
  type        = string
  default     = ""
}

variable "block_public_acls" {
  description = "Whether to block public ACLs for the S3 bucket"
  type        = bool
}

variable "block_public_policy" {
  description = "Whether to block public policies for the S3 bucket"
  type        = bool
}

variable "ignore_public_acls" {
  description = "Whether to ignore public ACLs for objects in the S3 bucket"
  type        = bool
}

variable "customized_s3_policies" {
  description = "customized_s3_policy"
  type        = any
  default = []
}
