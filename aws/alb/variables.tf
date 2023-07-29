variable "route53_zone_id" {
  description = "The Route53 zone ID"
  type        = string
}

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
  type        = list(object({
    id = string
  }))
  default     = []
}

variable "certificate_arn" {
  description = "The ARN of the SSL certificate"
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID"
  type        = string
}

variable "platform_prefix" {
  description = "The platform prefix"
  type        = string
}

variable "infra_environment" {
  description = "The infrastructure environment"
  type        = string
}
