data "aws_caller_identity" "current" {}

module "create_kms_key_bucket_tf_cloudtrail" {
  source  = "../standalone_resources/kms"
  description = "key-${var.customer_prefix}-${var.tenant_name}-s3-bucket-tf-cloudtrail"
  deletion_window_in_days = 7
}

module "create_s3_bucket_for_cloudtrail" {
    source  = "../s3"
    bucket_name              = "${var.customer_prefix}-${var.tenant_name}-s3-bucket-tf-cloudtrail"
    kms_key_arn              = module.create_kms_key_bucket_tf_cloudtrail.key_arn
    block_public_acls        = true
    block_public_policy      = true
    ignore_public_acls       = true
    restrict_public_buckets  = true
    is_logging               = true
    with_policy              = false
}

data "aws_iam_policy_document" "combined_policy_log_buckets" {
  statement {
    effect    = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = ["arn:aws:s3:::${var.customer_prefix}-${var.tenant_name}-s3-bucket-tf-cloudtrail"]
  }

  statement {
    effect    = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["arn:aws:s3:::${var.customer_prefix}-${var.tenant_name}-s3-bucket-tf-cloudtrail/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    effect    = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:*"]
    resources = [
      "${module.create_s3_bucket_for_cloudtrail.bucket_arn}",
      "${module.create_s3_bucket_for_cloudtrail.bucket_arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    effect    = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:*"]
    resources = [
      "${module.create_s3_bucket_for_cloudtrail.bucket_arn}",
      "${module.create_s3_bucket_for_cloudtrail.bucket_arn}/*"
    ]
    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = ["1.2"]
    }
  }
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = "${var.customer_prefix}-${var.tenant_name}-s3-bucket-tf-cloudtrail"
  policy = data.aws_iam_policy_document.combined_policy_log_buckets.json
}


module "create_log_group_cloudwatch" {
  source  = "../standalone_resources/cloudwatch_loggroup"
  name = "${var.customer_prefix}-${var.tenant_name}-cloudtrail"
}

resource "aws_cloudtrail" "main" {
  name                          = "${var.customer_prefix}-${var.tenant_name}-cloudtrail"
  s3_bucket_name                = "${var.customer_prefix}-${var.tenant_name}-s3-bucket-tf-cloudtrail"
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  enable_log_file_validation    = true
  
  kms_key_id                    = module.create_kms_key_bucket_tf_cloudtrail.key_arn

  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_cloudwatch_logs_role.arn
  cloud_watch_logs_group_arn    = "${module.create_log_group_cloudwatch.arn}:*"

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }
}

resource "aws_iam_role" "cloudtrail_cloudwatch_logs_role" {
  name = "${var.customer_prefix}-${var.tenant_name}-cloudtrail-cloudwatch-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch_logs_policy" {
  name   = "${var.customer_prefix}-${var.tenant_name}-cloudtrail-cloudwatch-logs-policy"
  role   = aws_iam_role.cloudtrail_cloudwatch_logs_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = "logs:CreateLogStream",
        Resource = "${module.create_log_group_cloudwatch.arn}:*"
      },
      {
        Effect = "Allow",
        Action = "logs:PutLogEvents",
        Resource = "${module.create_log_group_cloudwatch.arn}:*"
      }
    ]
  })
}

data "aws_iam_policy_document" "kms_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = [
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key_policy" "my_kms_key_policy" {
  key_id  = module.create_kms_key_bucket_tf_cloudtrail.key_id
  policy  = data.aws_iam_policy_document.kms_policy.json
}