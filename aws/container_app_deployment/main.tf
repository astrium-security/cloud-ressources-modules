module "ecs_task_definition" {
  source                =   "../standalone_resources/ecs_task_definition"
  prefix                =   var.prefix
  container_name        =   var.container_name
  image                 =   var.container_image
  app_environment       =   var.app_environment
  
  network_mode              =   "awsvpc"   
  requires_compatibilities  =   ["FARGATE"]

  cpu                   =   var.cpu
  memory                =   var.memory
  container_port        =   var.container_port
  host_port             =   var.host_port
  region                =   var.region

}

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