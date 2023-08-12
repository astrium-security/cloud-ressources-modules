
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
  source = "../standalone_resources/s3"  # Adjust this path based on your actual module location

  prefix           = var.prefix
  app_environment  = var.infra_environment
  name             = "cloudtrail"
  kms_key_arn      = module.kms_s3_key.kms_key_arn
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}

resource "aws_cloudtrail" "main" {
  name                          = "main-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.bucket
  include_global_service_events = true 
  is_multi_region_trail         = true 

  enable_log_file_validation = true
  cloud_watch_logs_group_arn = aws_cloudwatch_log_group.cloudtrail.arn
  cloud_watch_logs_role_arn  = aws_iam_role.cloudtrail_cloudwatch.arn
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
