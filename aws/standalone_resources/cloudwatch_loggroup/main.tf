resource "aws_cloudwatch_log_group" "log_group" {
  name = var.name
  kms_key_id = module.create_kms_key.key_arn
  depends_on = [ module.create_kms_key ]
}

data "aws_caller_identity" "current" {}

module "create_kms_key" {
  source  = "../kms"
  description = "${var.name}-cloudwatch-loggroup"
  deletion_window_in_days = 7
}

data "aws_iam_policy_document" "kms_policy" {
  statement {
    effect    = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]  # Add CloudWatch Logs permissions
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions = [
      "kms:*"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key_policy" "my_kms_key_policy" {
  key_id  = module.create_kms_key.key_id
  policy  = data.aws_iam_policy_document.kms_policy.json
}