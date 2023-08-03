output "aws_lb_target_group_arn" {
  description = "The ID of the security group"
  value       = aws_lb_target_group.tg-app.arn
}

output "dns_name" {
  description = "The ID of the security group"
  value       = aws_lb.app_lb.dns_name
}

output "object" {
  description = "The ID of the security group"
  value       = aws_lb.app_lb.dns_name
}