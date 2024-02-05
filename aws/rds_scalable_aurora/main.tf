data "aws_rds_engine_version" "postgresql" {
  engine        = "aurora-postgresql"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.name}-db-subnet-group"
  subnet_ids = var.vpc.subnets.*.id

  tags = {
    Name = var.name
  }
}

resource "random_password" "password_root" {
  length           = 24
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

module "create_kms_key_db" {
  source  = "../standalone_resources/kms"
  description = "key-${var.name}-db"
  deletion_window_in_days = 7
}

data "aws_availability_zones" "available" {}

module "aurora_postgresql_serverlessv2" {
    source  = "terraform-aws-modules/rds-aurora/aws"
    version = "9.0.0"
    
    name              = var.name
    engine            = data.aws_rds_engine_version.postgresql.engine
    engine_mode       = "provisioned"
    engine_version    = data.aws_rds_engine_version.postgresql.version
    storage_encrypted = true

    enabled_cloudwatch_logs_exports = ["postgresql"]

    availability_zones        = data.aws_availability_zones.available.names

    kms_key_id                      = module.create_kms_key_db.key_arn

    master_username   = "root"
    manage_master_user_password = false
    master_password   =   random_password.password_root.result

    vpc_id               = var.vpc.vpc_id
    security_group_rules = {
      vpc_ingress = {
        cidr_blocks = var.vpc.subnets.*.cidr_block 
      }
    }
    db_subnet_group_name    =   aws_db_subnet_group.db_subnet_group.name

    monitoring_interval = 60

    backup_retention_period = 30
    preferred_backup_window = "07:00-09:00"

    apply_immediately   = true
    skip_final_snapshot = true

    serverlessv2_scaling_configuration = {
        min_capacity = var.min_acu_capacity
        max_capacity = var.max_acu_capacity
    }

    instance_class = "db.serverless"
    instances = {
        one = {
            availability_zone = data.aws_availability_zones.available.names[0]
        }
    }

    db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name

    tags = {
        business_hours_only = var.business_hours_only
    }

    autoscaling_enabled      = true
    autoscaling_min_capacity = var.min_capacity
    autoscaling_max_capacity = var.max_capacity
}


resource "aws_rds_cluster_parameter_group" "this" {
  name        = "pg-cluster-parameters-${var.name}"
  family      = data.aws_rds_engine_version.postgresql.parameter_group_family

  parameter {
    name         = "rds.force_ssl"
    value        = "0"
    apply_method = "pending-reboot"
  }
}

module "add_parameters_secrets_db" {
    source      = "../standalone_resources/ssm_parameter_store"
    type        = "SecureString"
    description = "Root DB Password"  
    data_value   = module.aurora_postgresql_serverlessv2.cluster_master_password
    infra_or_app = "infra"
    component   = "database"
    name        = "PGSQL_CLUSTER_MASTER_PASSWORD"
}

module "add_parameters_writers_endpoints" {
    source      = "../standalone_resources/ssm_parameter_store"
    type        = "String"
    description = "Writers Endpoints"  
    data_value   = module.aurora_postgresql_serverlessv2.cluster_endpoint
    infra_or_app = "infra"
    component   = "database"
    name        = "PGSQL_CLUSTER_ENDPOINT"
}

module "add_parameters_readers_endpoints" {
    source      = "../standalone_resources/ssm_parameter_store"
    type        = "String"
    description = "Readers Endpoints"  
    data_value   = module.aurora_postgresql_serverlessv2.cluster_reader_endpoint
    infra_or_app = "infra"
    component   = "database"
    name        = "PGSQL_CLUSTER_READERS_ENDPOINT"
}