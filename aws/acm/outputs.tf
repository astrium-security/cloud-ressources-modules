output "certificate_arn" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.cert_public.arn
}

output "validation_record_fqdns" {
  description = "The FQDNs of the validation records for the ACM certificate"
  value       = aws_acm_certificate_validation.cert_validation_public.validation_record_fqdns
}

output "domain_name" {
  description = "The ARN of the ACM certificate"
  value       = aws_acm_certificate.cert_public.domain_name
}
