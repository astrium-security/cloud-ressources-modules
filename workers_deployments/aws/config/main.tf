# Create registry pour l'app 
module "create_ecr_registry" {
  source  = "../../../aws/standalone_resources/ecr"
  name = "${var.app_env}-${var.app_name}"
}

module "app" {
  source              = "../../../../terraform-modules/aws/container_worker_deployment"
  prefix              = "apps"
  region = var.region

  container_name      = "${var.app_name}"
  app_environment     = var.app_env
  vpc_id              = data.aws_vpc.selected.id
  public_subnets      = values(data.aws_subnet.public)

  cpu = var.app_cpu_container
  memory = var.app_ram_container
  
  container_image = var.app_image
  
  mount_efs = "/data/"

  container_env = [
        {
          "name" : "APP_ENV",
          "value" : var.app_env
        },
        {
          "name" : "APP_INFRA_ENV",
          "value" : var.infra_env
        },
        {
          "name" : "APP_PROVIDER",
          "value" : "aws"
        },
        {
          "name" : "APP_REGION",
          "value" : var.region
        }
    ]
  
  path_health     = var.app_health

  container_port  = var.container_port
  host_port       = var.host_port

  open_others_ports      = []

  cluster    =   data.aws_ecs_cluster.all
  
  route53_zone_internal = null
  cloudflare_zone_id    = var.cloudflare_zone_id
  cloudflare_tunnel     = null

  is_autoscale          = var.is_autoscale

  cpu_val_threshold     = 60
  memory_val_threshold  = 70
  min_capacity_scale    = 1
  max_capacity_scale    = 100
}

data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["aws-controltower-VPC"]
  }
}

data "aws_ecs_cluster" "all" {
  cluster_name = "platform-${var.infra_env}"
}

output "ecs_cluster_id" {
  value = data.aws_ecs_cluster.all.arn
}

output "vpc_id" {
  value = data.aws_vpc.selected.id
}


data "aws_subnets" "public_ids" {
  filter {
    name   = "tag:Name"
    values = ["Public*"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public_ids.ids)

  id = each.value
}
output "public_subnets" {
  value = values(data.aws_subnet.public)
}