module "create_kms_key_bucket_aws_config" {
  source  = "../standalone_resources/kms"
  description = "key-${var.bucket_name}-s3-bucket"
  deletion_window_in_days = 7
}

module "create_s3_bucket_for_aws_config" {
    source  = "../s3"
    bucket_name              = "${var.bucket_name}-s3-bucket"
    kms_key_arn              = module.create_kms_key_bucket_aws_config.key_arn
    block_public_acls        = false
    block_public_policy      = true
    ignore_public_acls       = true
    restrict_public_buckets  = true
    is_logging               = true
}