provider "random" {}

module "kms_s3_key" {
    source                  = "../standalone_resources/kms"
    prefix                  = var.prefix
    app_environment         = var.infra_environment
    description             = "cloudtrail"
    deletion_window_in_days = 7
    enable_key_rotation     = false
    multi_region            = false
    key_name                = "cloudtrail"
}

module "my_s3_bucket" {
  source = "../standalone_resources/s3"

  prefix           = var.prefix
  app_environment  = var.infra_environment
  name             = "cloudtrail"
  kms_key_arn      = module.kms_s3_key.kms_key_arn
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

resource "aws_guardduty_detector" "default" {
  enable = true
}

resource "aws_accessanalyzer_analyzer" "example" {
  analyzer_name = "${var.prefix}-analyzer"
  type          = "ACCOUNT"

  tags = {
    Name        = "${var.prefix}"
    Environment = var.infra_environment
  }
}

resource "aws_cloudtrail" "main" {
  depends_on = [aws_cloudwatch_log_group.cloudtrail, aws_s3_bucket_policy.cloudtrail_policy]
  name                          = "main-trail"
  s3_bucket_name                = module.my_s3_bucket.s3_bucket_name
  include_global_service_events = true 
  is_multi_region_trail         = true 
}

resource "aws_cloudwatch_log_group" "cloudtrail" {
  name = "CloudTrail/DefaultLogGroup"
}

resource "aws_iam_role" "cloudtrail_cloudwatch" {
  name = "CloudTrailCloudWatchRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      }
    ]
  })
}

resource "aws_iam_role_policy" "cloudtrail_cloudwatch_policy" {
  name = "CloudTrailCloudWatchPolicy"
  role = aws_iam_role.cloudtrail_cloudwatch.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogStream"
        ],
        Effect   = "Allow",
        Resource = aws_cloudwatch_log_group.cloudtrail.arn
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = module.my_s3_bucket.s3_bucket_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "CloudTrailAclCheck",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com",
        },
        Action   = "s3:GetBucketAcl",
        Resource = "arn:aws:s3:::${module.my_s3_bucket.s3_bucket_name}"
      },
      {
        Sid    = "CloudTrailWrite",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com",
        },
        Action   = "s3:PutObject",
        Resource = "arn:aws:s3:::${module.my_s3_bucket.s3_bucket_name}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}
