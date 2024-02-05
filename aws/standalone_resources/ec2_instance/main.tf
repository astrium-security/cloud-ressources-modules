module "create_kms_key_ebs_volume" {
  source  = "../kms"
  description = "${var.instance_name}-ebs-volume"
  deletion_window_in_days = 7
}

resource "aws_instance" "simple-instance" {
  count                       = var.total_instance_to_create
  ami                         = var.default_ami 
  instance_type               = var.instance_type 
  
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group
  
  associate_public_ip_address = var.set_public_ip_address
  
  key_name                    = var.key_name
  user_data                   = var.user_data
  
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name

  tenancy = "default"

  metadata_options {
    http_endpoint               = "enabled"  
    http_tokens                 = "required" 
    http_put_response_hop_limit = 1          
  }

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = var.root_volume_type
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = module.create_kms_key_ebs_volume.key_arn
    tags = {
      auto_snapshots = "true"
    }
  }

  tags = {
    Name = "${var.instance_name}"
    business_hours_only = var.business_hours_only
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "${var.instance_name}_profile"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.instance_name}_profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_policy" "kms_policy" {
  name        = "${var.instance_name}_KMSAccessPolicy"
  description = "Policy for allowing EC2 instances to use the KMS key"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ],
        Effect = "Allow",
        Resource = module.create_kms_key_ebs_volume.key_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "kms_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.kms_policy.arn
}