resource "aws_ssm_parameter" "secret" {
  name        = "/${var.infra_or_app}/${var.component}/${var.name}"
  description = "${var.description}"
  type        = var.type
  value       = var.data_value
  overwrite = true
}