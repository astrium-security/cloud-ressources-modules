resource "random_id" "name_suffix" {
  byte_length = 4
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "bucket" {
  bucket = var.create_random_suffix ? "${var.prefix}-${var.app_environment}-${var.name}-${random_id.name_suffix.hex}" : "${var.prefix}-${var.app_environment}-${var.name}"
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = var.create_random_suffix ? "log-${var.prefix}-${var.app_environment}-${var.name}-${random_id.name_suffix.hex}" : "log-${var.prefix}-${var.app_environment}-${var.name}"
}


resource "aws_s3_bucket_versioning" "versioning_bucket" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_sse" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn != null && var.kms_key_arn != "" ? var.kms_key_arn : null
      sse_algorithm     = var.kms_key_arn != null && var.kms_key_arn != "" ? "aws:kms" : "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_block_public" {
  bucket = aws_s3_bucket.bucket.id
  block_public_acls   = var.block_public_acls
  block_public_policy = var.block_public_policy
  ignore_public_acls = var.ignore_public_acls
}

# Logging S3 Bucket
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.log_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "write-log" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]

  bucket = aws_s3_bucket.log_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "b_logging" {
  bucket = aws_s3_bucket.bucket.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}

resource "aws_cloudtrail" "s3_object_read_logger" {
  name                          = "${var.prefix}-${var.app_environment}-${var.name}-${random_id.name_suffix.hex}-read-logger"
  s3_bucket_name                = "${var.prefix}-${var.app_environment}-cloudtrail-${data.aws_caller_identity.current.account_id}"
  include_global_service_events = true

  event_selector {
    read_write_type           = "ReadOnly"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"

      values = ["${aws_s3_bucket.bucket.arn}/"]
    }
  }
}

resource "aws_cloudtrail" "s3_object_write_logger" {
  name                          = "${var.prefix}-${var.app_environment}-${var.name}-${random_id.name_suffix.hex}-write-logger"
  s3_bucket_name                = "${var.prefix}-${var.app_environment}-cloudtrail-${data.aws_caller_identity.current.account_id}"
  include_global_service_events = true

  event_selector {
    read_write_type           = "WriteOnly"
    include_management_events = true

    data_resource {
      type = "AWS::S3::Object"

      values = ["${aws_s3_bucket.bucket.arn}/"]
    }
  }
}