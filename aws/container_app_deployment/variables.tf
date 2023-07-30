variable "prefix" {
  description = "The prefix for the resources"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "app_environment" {
  description = "Application environment"
  type        = string
}

variable "cluster_id" {
  description = "ID of the ECS cluster"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
}

variable "container_image" {
  description = "Container image"
  type        = string
}

variable "cpu" {
  description = "CPU value for the task definition"
  type        = string
}

variable "memory" {
  description = "Memory value for the task definition"
  type        = string
}

variable "host_port" {
  description = "Host port"
  type        = number
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "route53_zone_id" {
  description = "Route53 zone ID"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(any)
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "container_definitions" {
  description = "container_definitions"
  type        = string
}