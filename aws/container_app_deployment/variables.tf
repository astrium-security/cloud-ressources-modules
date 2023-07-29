variable "prefix" {
  description = "Prefix for resources"
  type        = string
}

variable "container_name" {
  description = "Container name"
  type        = string
}

variable "container_image" {
  description = "Container image"
  type        = string
}

variable "app_environment" {
  description = "Application environment"
  type        = string
}

variable "cpu" {
  description = "CPU units for the task definition"
  type        = string
}

variable "memory" {
  description = "Memory for the task definition"
  type        = string
}

variable "container_port" {
  description = "Port on the container to bind to"
  type        = number
}

variable "host_port" {
  description = "Port on the host to bind to"
  type        = number
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(object({cidr_block = string}))
}
