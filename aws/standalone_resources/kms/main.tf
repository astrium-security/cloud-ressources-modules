
resource "aws_kms_key" "key" {
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation = true
}

resource "aws_kms_alias" "key_alias" {
  #name          = "alias/${var.description}"
  target_key_id = aws_kms_key.key.key_id
}
