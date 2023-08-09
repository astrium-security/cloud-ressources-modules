resource "aws_ecs_service" "main_app" {
    name                               = "${var.prefix}-${var.container_name}-${var.app_environment}-service"
    cluster                            = var.cluster.cluster_arn

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

  dynamic "load_balancer" {
        for_each = var.tg_others_ports
        content {
            target_group_arn = var.tg_others_ports[load_balancer.key].arn  # Assuming you have a map of target group ARNs corresponding to each port
            container_name   = "${var.prefix}-${var.container_name}-${var.app_environment}-container"
            container_port   = var.open_others_ports[load_balancer.key] #load_balancer.value
        }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_appautoscaling_target" "ecs_target" {
  count              =  var.is_autoscale ? 1 : 0
  max_capacity       =  var.max_capacity_scale
  min_capacity       =  var.min_capacity_scale
  resource_id        =  "service/${var.cluster.cluster_name}/${aws_ecs_service.main_app.name}"
  scalable_dimension =  "ecs:service:DesiredCount"
  service_namespace  =  "ecs"
}

resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  count              =  var.is_autoscale ? 1 : 0
  name               = "${var.prefix}-${var.container_name}-${var.app_environment}-memory-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[count.index].service_namespace
 
  target_tracking_scaling_policy_configuration {
   predefined_metric_specification {
     predefined_metric_type = "ECSServiceAverageMemoryUtilization"
   }
 
   target_value       = var.memory_val_threshold
  }
}

resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  count              =  var.is_autoscale ? 1 : 0
  name               = "${var.prefix}-${var.container_name}-${var.app_environment}-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_target[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target[count.index].service_namespace
 
  target_tracking_scaling_policy_configuration {
   predefined_metric_specification {
     predefined_metric_type = "ECSServiceAverageCPUUtilization"
   }
 
   target_value       = var.cpu_val_threshold
  }
}