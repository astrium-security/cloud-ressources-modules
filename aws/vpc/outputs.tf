output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "public_subnets" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public.*.id
}

output "private_subnets" {
  description = "IDs of the private subnets"
  value       = aws_subnet.private.*.id
}

output "internet_gateway" {
  description = "The ID of the internet gateway"
  value       = aws_internet_gateway.gw.id
}

output "public_route_table" {
  description = "The ID of the public route table"
  value       = aws_route_table.public.id
}
