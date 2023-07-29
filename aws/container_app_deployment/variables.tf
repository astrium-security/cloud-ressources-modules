variable "prefix" {
  description = "The prefix to use for all resources"
  type        = string
}

variable "container_name" {
  description = "The name of the container"
  type        = string
}

variable "app_environment" {
  description = "The application environment"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}

variable "public_subnets" {
  description = "A list of public subnets"
  type        = list(object({ cidr_block = string }))
  default     = []
}
