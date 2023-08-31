
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
  create_random_suffix  = false
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

locals {
  regions = [
    "us-east-1",
    "us-east-2",
    "us-west-1",
    "us-west-2",
    "eu-west-1",
    "eu-west-2",
    "eu-west-3",
    "eu-central-1",
    "ap-southeast-1",
    "ap-southeast-2",
    "ap-northeast-1",
    "ap-northeast-2",
    "ap-south-1",
    "ca-central-1",
    "sa-east-1",
    "eu-north-1",
    "me-south-1",
    "ap-east-1",
    "af-south-1"
  ]
}

resource "aws_config_configuration_recorder" "this" {
  for_each = { for region in local.regions : region => region }

  name     = "default"
  role_arn = aws_iam_role.config.arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

module "config_bucket" {
  source = "../standalone_resources/s3"

  prefix           = var.prefix
  app_environment  = var.infra_environment
  name             = "config"
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

resource "aws_s3_bucket_policy" "config_bucket_policy" {
  bucket = module.config_bucket.s3_bucket_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ],
        Effect = "Allow",
        Resource = [
          "${module.config_bucket.s3_bucket_arn}",
          "${module.config_bucket.s3_bucket_arn}/*"
        ],
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_config_delivery_channel" "this" {
  for_each = { for region in local.regions : region => region }

  name           = "default"
  s3_bucket_name = module.config_bucket.s3_bucket_name
  s3_key_prefix  = "config"
  snapshot_delivery_properties {
    delivery_frequency = "TwentyFour_Hours"
  }
}

resource "aws_iam_role" "config" {
  name = "awsconfig-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}
