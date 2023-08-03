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
    container_port        =   var.container_port

    is_autoscale          = var.is_autoscale

    cpu_val_threshold     = var.cpu_val_threshold
    memory_val_threshold  = var.memory_val_threshold
    min_capacity_scale    = var.min_capacity_scale
    max_capacity_scale    = var.max_capacity_scale
}

module "dns" {
  source                =   "../standalone_resources/dns_create_record"
  route53_zone_id       =   var.route53_zone_internal
  app_name              =   var.container_name
  app_env               =   var.app_environment
  prefix                =   var.prefix
  cloudflare_zone_id    =   var.cloudflare_zone_id
  cloudflare_tunnel     =   var.cloudflare_tunnel
  region                =   "eu-west-1"
  type_record           =   "CNAME"
  targets               =   [module.alb.dns_name]
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
  path_health           =   var.path_health
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

  cpu                   =   var.cpu
  memory                =   var.memory
  container_port        =   var.container_port
  host_port             =   var.host_port
  region                =   var.region
  public_subnets        =   var.public_subnets
  security_group        =   [module.security_groups.id]
}

module "security_groups" {
  source                = "../standalone_resources/security_group"
  prefix                = var.prefix
  resource_name         = var.container_name
  environment           = var.app_environment
  vpc_id                = var.vpc_id

  ingress_protocol      = "tcp"
  ingress_from_port     = var.container_port
  ingress_to_port       = var.container_port
  ingress_cidr_blocks   = var.public_subnets.*.cidr_block 

  egress_protocol       = "-1"
  egress_from_port      = 0
  egress_to_port        = 0
  egress_cidr_blocks    = ["0.0.0.0/0"]
}
