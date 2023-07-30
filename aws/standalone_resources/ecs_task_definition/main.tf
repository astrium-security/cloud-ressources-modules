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
    }
  }

  container_definitions = jsonencode([{
    name        = "${var.prefix}-${var.container_name}-${var.app_environment}-container"
    image       = var.image
    essential   = true
    environment = var.container_env

    mountPoints = [{
      sourceVolume  = "efs"
      containerPath = "/data"
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

resource "aws_efs_mount_target" "all" {
  count                   = length(var.public_subnets)
  file_system_id  = aws_efs_file_system.efs.id
  subnet_id       =  element(var.public_subnets, count.index)
}

resource "aws_efs_file_system" "efs" {
  creation_token = "${var.prefix}-${var.container_name}-${var.app_environment}-data"
  tags = {
    Name = "${var.prefix}-${var.container_name}-${var.app_environment}-data"
  }
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
  name = "${var.prefix}/${var.app_environment}/${var.container_name}/"
}