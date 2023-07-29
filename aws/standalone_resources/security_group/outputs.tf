output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.ecs_tasks-resource.id
}