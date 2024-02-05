locals {
  regions = [
    "us-east-1",
    "us-east-2",
    "us-west-1",
    "us-west-2",
    "eu-west-1",
    "eu-west-2",
    "eu-west-3",
    "eu-central-1",
    "ap-southeast-1",
    "ap-southeast-2",
    "ap-northeast-1",
    "ap-northeast-2",
    "ap-south-1",
    "ca-central-1",
    "sa-east-1",
    "eu-north-1",
    "me-south-1",
    "ap-east-1",
    "af-south-1"
  ]
}

module "create_cloudtrail" {
  source  = "../cloudtrail"
  customer_prefix = var.customer_prefix
  tenant_name = var.tenant_name
}

module "create_kms_key_bucket_aws_config" {
  source  = "../standalone_resources/kms"
  description = "key-${var.customer_prefix}-${var.tenant_name}-s3-bucket-aws-config"
  deletion_window_in_days = 7
}

module "create_s3_bucket_for_aws_config" {
    source  = "../s3"
    bucket_name              = "${var.customer_prefix}-${var.tenant_name}-s3-bucket-aws-config"
    kms_key_arn              = module.create_kms_key_bucket_aws_config.key_arn
    block_public_acls        = false
    block_public_policy      = true
    ignore_public_acls       = true
    restrict_public_buckets  = true
    is_logging               = true
}

resource "aws_iam_role" "config" {
  name = "aws-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_guardduty_detector" "default" {
  enable = true
}

#resource "aws_accessanalyzer_analyzer" "this" {
  #for_each = { for region in local.regions : region => region }
#  analyzer_name = "${var.customer_prefix}-${var.tenant_name}-analyzer"
#}

resource "aws_iam_account_password_policy" "this" {
  allow_users_to_change_password = true
  hard_expiry                    = false
  max_password_age               = 90  
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  require_uppercase_characters   = true
  password_reuse_prevention      = 5   
}

resource "aws_key_pair" "operator_keys" {
  for_each   = { for k, v in var.ssh_key_ops : k => v }
  key_name   = "operator-key-${each.key}"
  public_key = each.value
}

# Auto Snapshots ec2 Volumes
resource "aws_dlm_lifecycle_policy" "this" {
  description        = "EBS snapshot policy"
  execution_role_arn = aws_iam_role.this.arn

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "2 hours schedule"

      create_rule {
        interval      = 2
        interval_unit = "HOURS"
        times         = ["23:45"]
      }

      retain_rule {
        count = 42
      }

      copy_tags = false
    }

    target_tags = {
      "auto_snapshots" = "true"
    }
  }

  state = "ENABLED"
}

resource "aws_iam_role" "this" {
  name = "ebs-snapshots-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "dlm.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "this" {
  name = "ebs-snapshots-policy"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:CreateSnapshot",
          "ec2:DeleteSnapshot",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots"
        ],
        Effect = "Allow",
        Resource = "*"
      },
    ]
  })
}