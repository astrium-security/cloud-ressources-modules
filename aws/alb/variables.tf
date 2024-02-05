
variable "prefix" {
  description = "The prefix to use for all resources"
  type        = string
}

variable "container_name" {
  description = "The container name"
  type        = string
}

variable "app_environment" {
  description = "The application environment"
  type        = string
}

variable "public_subnet" {
  description = "The public subnet to attach the load balancer"
  type        = list(any)
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
}

variable "path_health" {
  description = "path health"
  type        = string
}

variable "open_others_ports" {
  description = "open_others_ports"
  default = []
  type        = any
}