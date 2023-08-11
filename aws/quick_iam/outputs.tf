output "iam_user_name" {
  description = "IAM user's name."
  value       = aws_iam_user.user.name
}

output "iam_policy_arn" {
  description = "IAM policy ARN."
  value       = aws_iam_policy.user-policy.arn
}

output "iam_access_key" {
  description = "IAM user's access key ID."
  value       = aws_iam_access_key.user
}
