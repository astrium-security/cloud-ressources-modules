#module "ecs_service" {
#  source              = "../standalone_resources/ecs_service"
#}

module "security_groups" {
  source                = "../standalone_resources/security_group"
  prefix                = var.prefix
  resource_name         = var.container_name
  environment           = var.app_environment
  vpc_id                = var.vpc_id

  ingress_protocol      = "tcp"
  ingress_from_port     = 80
  ingress_to_port       = 80
  ingress_cidr_blocks   = var.public_subnets.*.cidr_block 

  egress_protocol       = "-1"
  egress_from_port      = 0
  egress_to_port        = 0
  egress_cidr_blocks    = ["0.0.0.0/0"]
}