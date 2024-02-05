module "ecs_service" {
    source                =   "../standalone_resources/ecs_service"
    prefix                =   var.prefix
    container_name        =   var.container_name
    app_environment       =   var.app_environment
    cluster               =   var.cluster
    task_definition_arn   =   module.ecs_task_definition.main_app_task_definition_arn

    desired_count         =   1
    launch_type           =   "FARGATE"
    scheduling_strategy   =   "REPLICA"
    force_new_deployment  =   true
    security_groups       =   [module.security_groups.id]
    public_subnet         =   var.public_subnets
    
    target_group_arn      =   module.alb.aws_lb_target_group_arn
    tg_others_ports       =   module.alb.tg_others_ports
    open_others_ports     =   var.open_others_ports

    container_port        =   var.container_port

    is_autoscale          =   var.is_autoscale

    cpu_val_threshold     =   var.cpu_val_threshold
    memory_val_threshold  =   var.memory_val_threshold
    min_capacity_scale    =   var.min_capacity_scale
    max_capacity_scale    =   var.max_capacity_scale 

    depends_on = [ module.ecs_task_definition, module.alb, module.security_groups ]  
}

module "alb" {
  source                =   "../alb"
  prefix                =   var.prefix
  container_name        =   var.container_name
  app_environment       =   var.app_environment
  public_subnet         =   var.public_subnets
  vpc_id                =   var.vpc_id
  container_port        =   var.container_port
  path_health           =   var.path_health
  open_others_ports      =  var.open_others_ports
}

module "ecs_task_definition" {
  source                =   "../standalone_resources/ecs_task_definition"
  prefix                =   var.prefix
  container_name        =   var.container_name
  image                 =   var.container_image
  app_environment       =   var.app_environment

  container_env         =   var.container_env
  vpc_id                =   var.vpc_id
  mount_efs             =   var.mount_efs

  network_mode              =   "awsvpc"   
  requires_compatibilities  =   ["FARGATE"]
  entrypoint            =   var.entrypoint
  
  cpu                   =   var.cpu
  memory                =   var.memory
  container_port        =   var.container_port
  host_port             =   var.host_port
  region                =   var.region
  public_subnets        =   var.public_subnets
  security_group        =   [module.security_groups.id]
  open_others_ports      =  var.open_others_ports
}

module "security_groups" {
  source                = "../standalone_resources/security_group"
  prefix                = var.prefix
  resource_name         = var.container_name
  environment           = var.app_environment
  vpc_id                = var.vpc_id

  ingress_protocol      = "-1"
  ingress_from_port     = 0
  ingress_to_port       = 0
  ingress_cidr_blocks   = var.public_subnets.*.cidr_block 

  egress_protocol       = "-1"
  egress_from_port      = 0
  egress_to_port        = 0
  egress_cidr_blocks    = ["0.0.0.0/0"]
}