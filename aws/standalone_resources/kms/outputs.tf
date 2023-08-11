output "kms_key_id" {
  description = "The globally unique identifier for the KMS key."
  value       = aws_kms_key.key.key_id
}

output "kms_key_arn" {
  description = "The ARN of the KMS key."
  value       = aws_kms_key.key.arn
}

output "kms_alias_name" {
  description = "The display name of the alias."
  value       = aws_kms_alias.key_alias.name
}

output "kms_alias_arn" {
  description = "The ARN of the KMS alias."
  value       = aws_kms_alias.key_alias.arn
}
