resource "aws_ses_domain_identity" "domain" {
  domain = var.domain
}

resource "aws_ses_domain_dkim" "this" {
  domain = aws_ses_domain_identity.domain.domain
}

resource "aws_ses_domain_mail_from" "this" {
  domain           = aws_ses_domain_identity.domain.domain
  mail_from_domain = "bounce.${aws_ses_domain_identity.domain.domain}"
}

resource "aws_iam_user" "smtp_user" {
  name = "smtp_user_${var.infra_environment}"
}

resource "aws_iam_access_key" "smtp_user" {
  user = aws_iam_user.smtp_user.name
}

data "aws_iam_policy_document" "ses_sender" {
  statement {
    actions   = ["ses:SendRawEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ses_sender" {
  name        = "${var.infra_environment}-ses_sender"
  description = "Allows sending of e-mails via Simple Email Service"
  policy      = data.aws_iam_policy_document.ses_sender.json
}

resource "aws_iam_user_policy_attachment" "test-attach" {
  user       = aws_iam_user.smtp_user.name
  policy_arn = aws_iam_policy.ses_sender.arn
}

module "add_parameters_emails_access_key" {
    source      = "../standalone_resources/ssm_parameter_store"
    type        = "String"
    description = ""  
    data_value   = aws_iam_access_key.smtp_user.id
    infra_or_app = "infra"
    component   = "emails"
    name        = "SMTP_AWS_ACCESS_KEY"
}

module "add_parameters_emails_secret_key" {
    source      = "../standalone_resources/ssm_parameter_store"
    type        = "String"
    description = ""  
    data_value   = aws_iam_access_key.smtp_user.secret
    infra_or_app = "infra"
    component   = "emails"
    name        = "SMTP_AWS_SECRET_KEY"
}