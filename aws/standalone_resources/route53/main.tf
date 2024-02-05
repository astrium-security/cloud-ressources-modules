resource "aws_route53_zone" "primary" {
  name = var.name
  vpc {
    vpc_id = var.vpc_id
  }
}
