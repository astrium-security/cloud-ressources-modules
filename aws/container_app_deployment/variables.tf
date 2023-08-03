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

variable "cluster" {
  description = "ID of the ECS cluster"
  type        = any
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

variable "container_env" {
  description = "container_env"
  type        = any
}

variable "path_health" {
  description = "path_health"
  type        = string
}

variable "mount_efs" {
  description = "mount_efs"
  type        = string
}

variable "is_autoscale" {
  description = "is_autoscale"
  type        = bool
  default     = false
}

variable "max_capacity_scale" {
  description = "max_capacity_scale"
  type        = number
  default     = 2
}

variable "min_capacity_scale" {
  description = "min_capacity_scale"
  type        = number
  default     = 1
}

variable "memory_val_threshold" {
  description = "memory_val_threshold"
  type        = number
  default     = 80
}

variable "cpu_val_threshold" {
  description = "memory_val_threshold"
  type        = number
  default     = 60
}

variable "route53_zone_internal" {
  description = "route53_zone_internal"
  type        = any
}

variable "cloudflare_zone_id" {
  description = "The ID of the hosted zone to contain this record in Cloudflare."
  type        = string
}

variable "cloudflare_tunnel" {
  description = "cloudflare_tunnel"
  type        = string
}
