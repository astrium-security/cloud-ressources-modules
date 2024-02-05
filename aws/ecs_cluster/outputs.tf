output "cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the ECS cluster"
  value       = module.ecs.cluster_arn
}