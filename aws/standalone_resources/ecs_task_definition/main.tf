resource "aws_ecs_task_definition" "main_app" {
  family                   = "${var.prefix}-${var.container_name}-${var.app_environment}-task"
  network_mode             = var.network_mode
  requires_compatibilities = var.requires_compatibilities
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role_app.arn
  task_role_arn            = aws_iam_role.ecs_task_role_app.arn

  volume {
    name      = "efs"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs.id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.this.id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([{
    name        = "${var.prefix}-${var.container_name}-${var.app_environment}-container"
    image       = var.image
    essential   = true
    environment = var.container_env

    mountPoints = [{
      sourceVolume  = "efs"
      containerPath = "${var.mount_efs}"
    }]

    portMappings = [{
      protocol      = "tcp"
      containerPort = var.container_port
      hostPort      = var.host_port
    }]

    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.main-app.name
        awslogs-stream-prefix = "ecs"
        awslogs-region        = var.region
      }
    }
  }])
}

resource "aws_efs_access_point" "this" {
  file_system_id = aws_efs_file_system.efs.id

  posix_user {
    gid = 1000
    uid = 1000
  }

  root_directory {
    path = "${var.mount_efs}"

    creation_info {
      owner_gid   = 1000
      owner_uid   = 1000
      permissions = 755
    }
  }
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite"
    ]

    effect = "Allow"

    resources = [
      aws_efs_file_system.efs.arn,
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["true"]
    }
  }
}

resource "aws_efs_file_system_policy" "this" {
  file_system_id = aws_efs_file_system.efs.id
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "efs_access" {
  statement {
    actions = [
      "elasticfilesystem:ClientMount",
      "elasticfilesystem:ClientWrite"
    ]

    resources = [
      aws_efs_file_system.efs.arn
    ]
  }
}

resource "aws_iam_policy" "efs_access" {
  name   = "${var.prefix}-${var.container_name}-${var.app_environment}-efs-access"
  policy = data.aws_iam_policy_document.efs_access.json
}

resource "aws_iam_role_policy_attachment" "efs_access" {
  role       = aws_iam_role.task.name
  policy_arn = aws_iam_policy.efs_access.arn
}

resource "aws_iam_role" "ecs_task_execution_role_app" {
  name = "${var.prefix}-${var.container_name}-${var.app_environment}-ecsTaskExec"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_efs_file_system" "efs" {
  performance_mode = "generalPurpose"

  creation_token = "${var.prefix}-${var.container_name}-${var.app_environment}-volume"
  
  lifecycle_policy {
    transition_to_ia = "AFTER_7_DAYS"
  }

  tags = {
    Name = "${var.prefix}-${var.container_name}-${var.app_environment}-volume"
  }
}

resource "aws_efs_backup_policy" "policy" {
  file_system_id = aws_efs_file_system.efs.id

  backup_policy {
    status = "ENABLED"
  }
}

resource "aws_efs_mount_target" "all" {
  count          = length(var.public_subnets)
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = var.public_subnets[count.index].id
  security_groups = [module.security_groups.id]
}

module "security_groups" {
  source                = "../security_group"
  prefix                = var.prefix
  resource_name         = "${var.container_name}-${var.app_environment}-volume"
  environment           = "${var.app_environment}"
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

resource "aws_iam_role" "ecs_task_role_app" {
  name = "${var.prefix}-${var.container_name}-${var.app_environment}-ecsTask"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-app-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role_app.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs-task-execution-app-role-policy-attachment-ses" {
  role       = aws_iam_role.ecs_task_role_app.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "aws_cloudwatch_log_group" "main-app" {
  name = "/app/${var.prefix}/${var.app_environment}/${var.container_name}/"
}