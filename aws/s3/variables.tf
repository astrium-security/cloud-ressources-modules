variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

variable "kms_key_arn" {
  type        = string
  description = "ARN of the KMS key for bucket encryption"
}

variable "block_public_acls" {
  type        = bool
  description = "Block public ACLs"
  default     = true
}

variable "block_public_policy" {
  type        = bool
  description = "Block public policy"
  default     = true
}

variable "ignore_public_acls" {
  type        = bool
  description = "Ignore public ACLs"
  default     = true
}

variable "restrict_public_buckets" {
  type        = bool
  description = "Restrict public buckets"
  default     = true
}

variable "is_logging" {
  type        = bool
  description = "This bucket should be logging enabled or not"
  default     = true
}

variable "with_policy" {
  type        = bool
  description = "with_policy"
  default     = true
}

variable "create_iam_user" {
  type = bool
  description = "Create a user with access to the bucket"
  default = false
}