resource "random_id" "name_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.prefix}-${var.app_environment}-${var.name}-${random_id.name_suffix.hex}"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_sse" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "s3_block_public" {
  bucket = aws_s3_bucket.bucket.id

  # block public bucket
  block_public_acls   = var.block_public_acls
  block_public_policy = var.block_public_policy

  # block public objects
  ignore_public_acls = var.ignore_public_acls
}