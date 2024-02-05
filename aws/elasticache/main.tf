module "elasticache-redis_example_redis-clustered-mode" {
  source  = "umotif-public/elasticache-redis/aws"
  version = "3.5.0"

  name_prefix        = "${var.infra_environment}-${var.customer_prefix}-${var.name}"
  num_cache_clusters = var.num_cache_clusters
  node_type          = var.node_type

  cluster_mode_enabled    = true
  replicas_per_node_group = var.replicas_per_node_group
  num_node_groups         = var.num_node_groups

  engine_version           = var.engine_version
  port                     = 6379
  maintenance_window       = "mon:03:00-mon:04:00"
  snapshot_window          = "04:00-06:00"
  snapshot_retention_limit = var.snapshot_retention_limit

  automatic_failover_enabled = true
  multi_az_enabled = true

  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  auth_token                 = random_password.auth_token.result

  apply_immediately = true
  family            = var.family
  description       = var.description
  
  kms_key_id        = module.create_kms_key_redis.key_arn

  subnet_ids = var.subnet_ids.*.id
  vpc_id     = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]

  parameter = [
    {
      name  = "repl-backlog-size"
      value = "16384"
    }
  ]

  log_delivery_configuration = [
    {
      destination_type = "cloudwatch-logs"
      destination      = module.create_log_group_cloudwatch.name
      log_format       = "json"
      log_type         = "engine-log"
    }
  ]
  
  depends_on = [ module.cloudwatch_log_group ]
}

module "add_parameters_redis" {
    source      = "../standalone_resources/ssm_parameter_store"
    type        = "String"
    description = "Redis Endpoints"  
    data_value   = module.elasticache-redis_example_redis-clustered-mode.elasticache_replication_group_primary_endpoint_address
    infra_or_app = "infra"
    component   = "redis"
    name        = "REDIS_PRIMARY_ENDPOINT"
}

module "add_parameters_redis_port" {
    source      = "../standalone_resources/ssm_parameter_store"
    type        = "String"
    description = "Redis port"  
    data_value   = module.elasticache-redis_example_redis-clustered-mode.elasticache_port
    infra_or_app = "infra"
    component   = "redis"
    name        = "REDIS_PORT"
}

module "create_kms_key_redis" {
  source  = "../standalone_resources/kms"
  description = "key-${var.name}-redis"
  deletion_window_in_days = 7
}

module "cloudwatch_log_group" {
  source  = "../standalone_resources/cloudwatch_loggroup"
  name        = "redis-${var.infra_environment}-${var.customer_prefix}-${var.name}"
}

module "create_log_group_cloudwatch" {
  source  = "../standalone_resources/cloudwatch_loggroup"
  name = "${var.infra_environment}-${var.customer_prefix}-${var.name}"
}

resource "random_password" "auth_token" {
  length           = 24
  special          = false
  override_special = "!#$%&*()-_=+[]{}<>:?"
}