output "aws_lb_target_group_arn" {
  description = "The ID of the security group"
  value       = aws_lb_target_group.tg-app.arn
}
