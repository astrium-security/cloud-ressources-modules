

data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

resource "aws_lb" "app_lb" {
    name               = "${var.prefix}-${var.container_name}-${var.app_environment}-alb"
    internal           = true
    load_balancer_type = "application"
    security_groups    = [aws_security_group.lb_sg_app.id]
    subnets            = [for subnet in var.public_subnet.* : subnet.id]

    enable_deletion_protection = false

    # NEED TO FIX THIS
    #access_logs {
    #    bucket  = module.my_s3_bucket.bucket_id
    #    prefix  = "${var.container_name}-alb"
    #    enabled = true
    #}
}

resource "aws_lb_listener" "app_redirect" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-app.arn
  }
}

resource "aws_lb_target_group" "tg-app" {
  name        = "${var.container_name}-${var.app_environment}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = "3"
    interval            = "120"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "100"
    path                = var.path_health
    unhealthy_threshold = "2"
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_lb" "app_nlb" {
    count               = length(var.open_others_ports) > 0 ? 1 : 0
    name                = "${var.prefix}-${var.container_name}-${var.app_environment}-nlb"
    internal            = true
    load_balancer_type  = "network" 
    subnets             = [for subnet in var.public_subnet : subnet.id]

    enable_deletion_protection = false
}

resource "aws_lb_listener" "app_others_ports" {
  count               = length(var.open_others_ports)
  load_balancer_arn   = aws_lb.app_nlb[0].arn # Accessing the NLB ARN conditionally
  port                = var.open_others_ports[count.index]
  protocol            = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = element(aws_lb_target_group.tg-app_others_ports.*.arn, count.index)
  }
}

resource "aws_lb_target_group" "tg-app_others_ports" {
  count         = length(var.open_others_ports)
  name          = "${var.prefix}-${var.container_name}-${var.app_environment}-tg-${var.open_others_ports[count.index]}"
  port          = var.open_others_ports[count.index]
  protocol      = "TCP"
  target_type   = "ip"
  vpc_id        = var.vpc_id

  health_check {
    healthy_threshold   = "3"
    interval            = "120"
    protocol            = "TCP"
    timeout             = "100"
    unhealthy_threshold = "2"
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_security_group" "lb_sg_app" {
  name        = "${var.prefix}-${var.container_name}-${var.app_environment}-lb-sg"
  description = "Allow incoming traffic to the Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }

   ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow incoming HTTP connections"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "create_kms_key_bucket" {
  source  = "../standalone_resources/kms"
  description = "key-${var.prefix}-${var.container_name}-${var.app_environment}-s3-bucket"
  deletion_window_in_days = 7
}

module "my_s3_bucket" {
    source  = "../s3"
    bucket_name              = "logs-${var.prefix}-${var.container_name}-${var.app_environment}"
    kms_key_arn              = module.create_kms_key_bucket.key_arn
    block_public_acls        = false
    block_public_policy      = true
    ignore_public_acls       = true
    restrict_public_buckets  = true
    is_logging               = true
    with_policy              = false
}

data "aws_iam_policy_document" "combined_policy_log_buckets" {
    statement {
        principals {
        type        = "Service"
        identifiers = ["logdelivery.elb.amazonaws.com"]
        }

        actions = [
        "s3:PutObject"
        ]

        resources = [
        "${module.my_s3_bucket.bucket_arn}/*"
        ]

        condition {
        test     = "StringEquals"
        variable = "s3:x-amz-acl"

        values = [
            "bucket-owner-full-control"
        ]
        }
    }

    statement {
        effect    = "Allow"
        principals {
        type        = "Service"
        identifiers = ["cloudtrail.amazonaws.com"]
        }
        actions   = ["s3:GetBucketAcl"]
        resources = ["${module.my_s3_bucket.bucket_arn}"]
    }

  statement {
    effect    = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${module.my_s3_bucket.bucket_arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    effect    = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:*"]
    resources = [
      "${module.my_s3_bucket.bucket_arn}",
      "${module.my_s3_bucket.bucket_arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }

  statement {
    effect    = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:*"]
    resources = [
      "${module.my_s3_bucket.bucket_arn}",
      "${module.my_s3_bucket.bucket_arn}/*"
    ]
    condition {
      test     = "NumericLessThan"
      variable = "s3:TlsVersion"
      values   = ["1.2"]
    }
  }
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket = "logs-${var.prefix}-${var.container_name}-${var.app_environment}"
  policy = data.aws_iam_policy_document.combined_policy_log_buckets.json
  depends_on = [ module.my_s3_bucket ]
}