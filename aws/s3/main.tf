resource "aws_s3_bucket" "bucket" {
    bucket = var.bucket_name
    force_destroy = true
}

resource "aws_s3_bucket_acl" "bucket_acl" {
    bucket  = aws_s3_bucket.bucket.id
    acl     = "private"
    depends_on = [aws_s3_bucket_ownership_controls.s3_bucket_acl_ownership]
}

resource "aws_s3_bucket_versioning" "versioning" {
    bucket = aws_s3_bucket.bucket.id
    versioning_configuration {
        status = "Enabled"
    }
}

# Policy Document for Main S3 Buckets
data "aws_iam_policy_document" "combined_policy_main_buckets" {
  count   = var.with_policy ? 1 : 0
  statement {
    effect    = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:*"]
    resources = [
      "${aws_s3_bucket.bucket.arn}",
      "${aws_s3_bucket.bucket.arn}/*"
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
      "${aws_s3_bucket.bucket.arn}",
      "${aws_s3_bucket.bucket.arn}/*"
    ]
    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = ["1.2"]
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
    bucket = aws_s3_bucket.bucket.id

    rule {
        apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_arn
        sse_algorithm     = "aws:kms:dsse"
        }
    }
}

resource "aws_s3_bucket_policy" "main_bucket_policy" {
  count   = var.with_policy ? 1 : 0
  bucket = aws_s3_bucket.bucket.id  
  policy = data.aws_iam_policy_document.combined_policy_main_buckets[0].json
}

resource "aws_s3_bucket" "log_bucket" {
    count   = var.is_logging ? 1 : 0
    bucket  = "${var.bucket_name}-logs"
}


# Logging S3 Bucket
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.log_bucket[0].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
    count   = var.is_logging ? 1 : 0
    bucket = aws_s3_bucket.log_bucket[0].id

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "write-log" {
    count   = var.is_logging ? 1 : 0
    depends_on = [
        aws_s3_bucket_ownership_controls.example,
        aws_s3_bucket_public_access_block.example,
    ]

    bucket = aws_s3_bucket.log_bucket[0].id
    acl    = "log-delivery-write"
}

resource "aws_s3_bucket_logging" "example" {
    count   = var.is_logging ? 1 : 0
    bucket  = aws_s3_bucket.bucket.id

    target_bucket = aws_s3_bucket.log_bucket[0].id
    target_prefix = "log/"
}

resource "aws_s3_bucket_versioning" "versioning_log" {
    bucket  = aws_s3_bucket.log_bucket[0].id
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_log" {
    bucket  = aws_s3_bucket.log_bucket[0].id

    rule {
        apply_server_side_encryption_by_default {
        kms_master_key_id = var.kms_key_arn
        sse_algorithm     = "aws:kms"
        }
    }
}

resource "aws_s3_bucket_policy" "log_bucket_policy" {
  count   = var.with_policy ? 1 : 0
  bucket = aws_s3_bucket.log_bucket[0].id
  policy = data.aws_iam_policy_document.combined_policy_log_buckets[0].json
}

data "aws_iam_policy_document" "combined_policy_log_buckets" {
  count   = var.with_policy ? 1 : 0
  statement {
    effect    = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:*"]
    resources = [
      "${aws_s3_bucket.log_bucket[0].arn}",
      "${aws_s3_bucket.log_bucket[0].arn}/*"
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
      "${aws_s3_bucket.log_bucket[0].arn}",
      "${aws_s3_bucket.log_bucket[0].arn}/*"
    ]
    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = ["1.2"]
    }
  }
}

resource "aws_iam_user" "user" {
  count = var.create_iam_user ? 1 : 0
  name = "s3_user_${var.bucket_name}"
}

resource "aws_iam_access_key" "access_key" {
  count = var.create_iam_user ? 1 : 0
  user = aws_iam_user.user[0].name
}

resource "aws_iam_policy" "policy" {
  count = var.create_iam_user ? 1 : 0
  name = "s3-policy-${var.bucket_name}"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:*",
        ],
        Effect = "Allow",
        Resource = [
          "${aws_s3_bucket.bucket.arn}",
          "${aws_s3_bucket.bucket.arn}/*"
        ]
      },
      {
        Action = [
          "kms:GenerateDataKey",
				  "kms:Decrypt"
        ],
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach" {
  count = var.create_iam_user ? 1 : 0
  user       = aws_iam_user.user[0].name
  policy_arn = aws_iam_policy.policy[0].arn
}

module "add_parameters_user_id" {
  count = var.create_iam_user ? 1 : 0
  source      = "../standalone_resources/ssm_parameter_store"
  type        = "String"
  description = ""  
  data_value   = aws_iam_access_key.access_key[0].id
  infra_or_app = "infra"
  component   = "storage"
  name        = replace(upper("S3_${var.bucket_name}_id"), "-", "_")  
}

module "add_parameters_user_secret" {
  count = var.create_iam_user ? 1 : 0
  source      = "../standalone_resources/ssm_parameter_store"
  type        = "String"
  description = ""  
  data_value   = aws_iam_access_key.access_key[0].secret
  infra_or_app = "infra"
  component   = "storage"
  name        = replace(upper("S3_${var.bucket_name}_secret"), "-", "_") 
}

module "add_parameters_s3_bucket_name" {
  count = var.create_iam_user ? 1 : 0
  source      = "../standalone_resources/ssm_parameter_store"
  type        = "String"
  description = ""  
  data_value   = var.bucket_name
  infra_or_app = "infra"
  component   = "storage"
  name        = replace(upper("S3_${var.bucket_name}_name"), "-", "_")
}