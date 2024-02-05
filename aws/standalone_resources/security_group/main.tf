resource "aws_security_group" "sg" {
  name   = "${var.prefix}-${var.resource_name}-${var.environment}-sg"
  vpc_id = var.vpc_id

  ingress {
    protocol         = var.ingress_protocol
    from_port        = var.ingress_from_port
    to_port          = var.ingress_to_port
    cidr_blocks = var.ingress_cidr_blocks
  }

  egress {
    protocol         = var.egress_protocol
    from_port        = var.egress_from_port
    to_port          = var.egress_to_port
    cidr_blocks      = var.egress_cidr_blocks
  }

  tags = {
    Name        = "${var.prefix}-${var.resource_name}-${var.environment}-sg"
    Environment = var.environment
  }
}