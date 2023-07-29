# Use the standalone vpc module to create a VPC
module "ecs_service" {
  source              = "../standalone_resources/ecs_service"
}
