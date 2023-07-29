resource "aws_ecs_service" "main_app" {
    name                               = "${var.prefix}-${var.container_name}-${var.app_environment}-service"
    cluster                            = var.cluster_id
    task_definition                    = var.task_definition_arn
    desired_count                      = var.desired_count

    launch_type                        = var.launch_type
    scheduling_strategy                = var.scheduling_strategy
    force_new_deployment               = var.force_new_deployment

  network_configuration {
    security_groups  = var.security_groups
    subnets          = var.public_subnet.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn =  var.target_group_arn
    container_name   = "${var.prefix}-${var.container_name}-${var.app_environment}-container"
    container_port   = var.container_port
  }

  lifecycle {
    create_before_destroy = true
  }
}