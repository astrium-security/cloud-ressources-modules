# Create registry pour l'app 
module "create_ecr_registry" {
  source  = "../../../aws/standalone_resources/ecr"
  name = "${var.app_env}-${var.app_name}"
}

module "app" {
  source              = "../../../aws/container_service_deployment"
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

  is_autoscale          = true

  cpu_val_threshold     = 60
  memory_val_threshold  = 70
  min_capacity_scale    = 1
  max_capacity_scale    = 100
}

locals {
    dynamic_ingress_rules = {
      hostname = var.app_env != "prod" ?  "${var.app_name}-${var.app_env}.${var.region}.${var.public_domain}" : "${var.app_name}.${var.public_domain}"
      origin_request = []
      path = "/"
      service = "http://${module.app.alb.dns_name}"
    }
}

resource "aws_route53_record" "add_record_internal" {
  zone_id = data.aws_route53_zone.selected.zone_id
  
  name    = replace(local.dynamic_ingress_rules.hostname, "${var.region}.${var.public_domain}", "aws.${var.region}.${var.infra_env}.${var.internal_domain}") 
  type    = "CNAME"
  ttl     = "30"
  records = [replace(local.dynamic_ingress_rules.service, "http://", "")]
}

module "cloudflare_add_records" {
  source  = "../../../cloudflare/standalone_resources/add_record"

  zone_id = var.cloudflare_zone_id
  priority = null
  name    = local.dynamic_ingress_rules.hostname
  ttl     = 1
  type    = "CNAME"
  proxied = true
  value   = "${var.cloudflare_tunnel_id}.cfargotunnel.com"
}

data "aws_route53_zone" "selected" {
  name = "${var.infra_env}.${var.internal_domain}"
  private_zone = true

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