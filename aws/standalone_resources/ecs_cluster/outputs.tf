output "cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}
