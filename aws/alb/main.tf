resource "random_id" "unique_id" {
  byte_length = 4
}

data "aws_elb_service_account" "main_app" {}

data "aws_route53_zone" "selected" {
  zone_id         =  var.route53_zone_id
}

resource "aws_lb" "app_lb" {
    name               = "${var.prefix}-${var.container_name}-${var.app_environment}-alb"
    internal           = false
    load_balancer_type = "application"
    security_groups    = [aws_security_group.lb_sg_app.id]
    subnets            = [for subnet in var.public_subnet.* : subnet.id]

    enable_deletion_protection = true

    access_logs {
        bucket  = aws_s3_bucket.lb-app-logs.id
        prefix  = "${var.container_name}-alb"
        enabled = true
    }
}

resource "aws_route53_record" "www_app" {
  zone_id = var.route53_zone_id
  name    = "${var.container_name}.${data.aws_route53_zone.selected.name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.app_lb.dns_name]
}

resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-app.arn
  }
}

resource "aws_lb_listener" "app_redirect" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "tg-app" {
  name        = "${var.prefix}-${var.container_name}-${var.app_environment}-tg-${random_id.unique_id.hex}"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener_rule" "host_based_weighted_routing_app" {
  listener_arn = aws_lb_listener.app.arn
  
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-app.arn
  }

  condition {
    host_header {
      values = ["${var.container_name}.${data.aws_route53_zone.selected.name}"]
    }
  }
}

resource "aws_security_group" "lb_sg_app" {
  name        = "${var.prefix}-${var.container_name}-${var.app_environment}-lb-sg"
  description = "Allow incoming traffic to the Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
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

resource "aws_s3_bucket" "lb-app-logs" {
  bucket = "alb-logs-${var.prefix}-${var.container_name}-${var.app_environment}"
}

resource "aws_s3_bucket_policy" "lb-app-logs-policy" {
  bucket = aws_s3_bucket.lb-app-logs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
        ],
        Principal = {
          AWS = data.aws_elb_service_account.main_app.arn
        },
        Effect = "Allow",
        Resource = "${aws_s3_bucket.lb-app-logs.arn}/*",
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
    ],
  })
}