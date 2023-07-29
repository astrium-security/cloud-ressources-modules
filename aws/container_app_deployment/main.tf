module "ecs_service" {
    source                =   "../standalone_resources/ecs_service"
    prefix                =   var.prefix
    container_name        =   var.container_name
    app_environment       =   var.app_environment
    cluster_id            =   var.cluster_id
    task_definition_arn   =   module.ecs_task_execution_role_arn.ecs_task_execution_role_arn
    desired_count         =   1
    launch_type           =   "FARGATE"
    scheduling_strategy   =   "REPLICA"
    force_new_deployment  =   true
    security_groups       =   module.security_groups
    public_subnet         =   var.public_subnets
    target_group_arn      =   module.alb.aws_lb_target_group_arn
    container_port        =   var.container_port
}

module "alb" {
  source                =   "../alb"
  route53_zone_id       =   var.route53_zone_id
  prefix                =   var.prefix
  container_name        =   var.container_name
  app_environment       =   var.app_environment
  public_subnet         =   var.public_subnets
  certificate_arn       =   var.certificate_arn
  vpc_id                =   var.vpc_id
  container_port        =   var.container_port
}

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