
data "aws_elb_service_account" "main_app" {}

data "aws_route53_zone" "selected" {
  zone_id         =  var.route53_zone_id
}

resource "aws_lb" "app_lb" {
    name               = "${var.prefix}-${var.container_name}-${var.app_environment}-alb"
    internal           = true
    load_balancer_type = "application"
    security_groups    = [aws_security_group.lb_sg_app.id]
    subnets            = [for subnet in var.public_subnet.* : subnet.id]

    enable_deletion_protection = false

    access_logs {
        bucket  = module.my_s3_bucket.s3_bucket_id
        prefix  = "${var.container_name}-alb"
        enabled = true
    }

    #depends_on = [module.my_s3_bucket]
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
  name        = "${var.prefix}-${var.container_name}-${var.app_environment}-tg"
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
    # Conditionally create the LB if open_others_ports has one or more entries
    count               = length(var.open_others_ports) > 0 ? 1 : 0
    name                = "${var.prefix}-${var.container_name}-${var.app_environment}-nlb"
    internal            = true
    load_balancer_type  = "network" # For Network Load Balancer
    subnets             = [for subnet in var.public_subnet : subnet.id] # Updated for-each loop

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

module "my_s3_bucket" {
  source = "../standalone_resources/s3"

  prefix           = var.prefix
  app_environment  = var.app_environment
  name             = "${var.container_name}"
  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
}