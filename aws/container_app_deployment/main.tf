#module "ecs_service" {
#    source                =   "../standalone_resources/ecs_service"
#    prefix                =   var.prefix
#    container_name        =   var.container_name
#    app_environment       =   var.app_environment
#    cluster_id            =   var.cluster_id
#    task_definition_arn   =   module.ecs_task_definition.arn
#    desired_count         =   1
#    launch_type           =   ""
#    scheduling_strategy   =   ""
#    force_new_deployment  =   true
#    security_groups       =   module.security_groups
#    public_subnet         =   var.public_subnets
#    target_group_arn      =   ""
#    container_port        =   var.container_port
#}

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