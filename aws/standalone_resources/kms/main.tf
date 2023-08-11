resource "aws_kms_key" "key" {
  description = "${var.prefix}-${var.app_environment}-${var.description}"
  key_usage   = "ENCRYPT_DECRYPT"

  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.enable_key_rotation
  multi_region            = var.multi_region
}

resource "aws_kms_alias" "key_alias" {
  name          = "alias/${var.prefix}-${var.app_environment}-${var.key_name}"
  target_key_id = aws_kms_key.s3_key.key_id
}
