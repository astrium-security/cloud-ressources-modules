provider "random" {}

resource "random_string" "unique_string" {
  length  = 16  
  special = false
  upper   = false  
  lower   = true
  number  = true
}

resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "cloudtrail-${random_string.unique_string.result}" 
  acl    = "private"

  lifecycle_rule {
    enabled = true

    noncurrent_version_expiration {
      days = var.noncurrent_version_expiration
    }
  }
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
