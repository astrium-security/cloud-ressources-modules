variable "prefix" {
  description = "The prefix to use for all resources"
  type        = string
}

variable "container_name" {
  description = "The name of the container"
  type        = string
}

variable "image" {
  description = "The docker image"
  type        = string
}

variable "app_environment" {
  description = "The application environment"
  type        = string
}

variable "network_mode" {
  description = "The network mode for the task"
  type        = string
  default     = "awsvpc"
}

variable "requires_compatibilities" {
  description = "The launch type required by the task"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "cpu" {
  description = "The amount of CPU used by the task"
  type        = string
}

variable "memory" {
  description = "The amount of memory used by the task"
  type        = string
}

variable "container_port" {
  description = "The port on the container to associate with the load balancer"
  type        = number
}

variable "host_port" {
  description = "The port on the instance to associate with the load balancer"
  type        = number
}

variable "region" {
  description = "The region in which to create the resources"
  type        = string
  default     = "us-east-1"
}

variable "container_env" {
  description = "container_env"
  type        = any
}

variable "public_subnets" {
  description = "public_subnets"
  type        = any
}

variable "security_group" {
  description = "security_group"
  type        = any
}

variable "vpc_id" {
  description = "vpc_id"
  type        = any
}