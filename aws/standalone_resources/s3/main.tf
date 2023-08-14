resource "random_id" "name_suffix" {
  byte_length = 4
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.prefix}-${var.app_environment}-${var.name}-${random_id.name_suffix.hex}"
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

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "cloudtrail-${aws_s3_bucket.bucket.bucket}"
}

resource "aws_s3_bucket_versioning" "versioning_bucket_cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.bucket
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck20150319",
        Effect    = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action    = "s3:GetBucketAcl",
        Resource  = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_logs.bucket}"
      },
      {
        Sid       = "AWSCloudTrailWrite20150319",
        Effect    = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action    = "s3:PutObject",
        Resource  = "arn:aws:s3:::${aws_s3_bucket.cloudtrail_logs.bucket}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_cloudtrail" "s3_monitoring" {
  name           = "s3-bucket-${aws_s3_bucket.bucket.bucket}"
  s3_bucket_name = aws_s3_bucket.cloudtrail_logs.bucket

  enable_log_file_validation = true

  event_selector {
    read_write_type           = "All"
    include_management_events = false

    data_resource {
      type = "AWS::S3::Object"
      values = ["${aws_s3_bucket.bucket.arn}/"]
    }
  }
}
