resource "random_id" "name_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.prefix}-${var.app_environment}-${var.name}-${random_id.name_suffix.hex}"
  acl           = "private"
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
  bucket = "cloudtrail-${aws_s3_bucket.bucket}"
  acl    = "private"

  versioning {
    enabled = true
  }

  # This bucket policy ensures that AWS CloudTrail can write logs to the bucket.
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudTrailLogs"
        Effect    = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action    = "s3:PutObject"
        Resource  = "${self.arn}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# Create CloudTrail to monitor the target S3 bucket.
resource "aws_cloudtrail" "s3_monitoring" {
  name           = "s3-bucket-${aws_s3_bucket.bucket}"
  s3_bucket_name = aws_s3_bucket.cloudtrail_logs.bucket

  enable_log_file_validation = true

  event_selector {
    read_write_type           = "All"
    include_management_events = false

    data_resource {
      type = "AWS::S3::Object"

      # This will monitor all objects within the target bucket.
      values = ["${aws_s3_bucket.bucket.arn}/"]
    }
  }
}
