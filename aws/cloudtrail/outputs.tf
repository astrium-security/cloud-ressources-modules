output "s3_bucket_name" {
  description = "The name of the S3 bucket used for cloudtrail logs"
  value       = aws_s3_bucket.cloudtrail_logs.bucket
}

output "cloudtrail_name" {
  description = "The name of the CloudTrail"
  value       = aws_cloudtrail.main.name
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group for CloudTrail"
  value       = aws_cloudwatch_log_group.cloudtrail.name
}

output "cloudtrail_cloudwatch_role_name" {
  description = "The name of the IAM role for CloudTrail to CloudWatch"
  value       = aws_iam_role.cloudtrail_cloudwatch.name
}
