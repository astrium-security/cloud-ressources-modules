resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster-${var.infra_environment}"
  tags = {
    Name        = "${var.prefix}-cluster-${var.infra_environment}"
    Environment = var.infra_environment
  }
}