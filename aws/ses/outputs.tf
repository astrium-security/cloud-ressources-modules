output "mail_from_domain" {
  value = aws_ses_domain_mail_from.this.mail_from_domain
}

output "verification_token" {
  value = aws_ses_domain_identity.domain.verification_token
}

output "dkim_tokens" {
  value = aws_ses_domain_dkim.this.dkim_tokens
}
