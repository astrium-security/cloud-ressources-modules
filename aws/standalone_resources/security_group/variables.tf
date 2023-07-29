variable "prefix" {
  description = "The prefix to use for all resources"
  type        = string
}

variable "resource_name" {
  description = "The name of the resource"
  type        = string
}

variable "environment" {
  description = "The infrastructure environment"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "ingress_protocol" {
  description = "Protocol to be used for ingress"
  type        = string
  default     = "tcp"
}

variable "ingress_from_port" {
  description = "The starting port for ingress"
  type        = number
}

variable "ingress_to_port" {
  description = "The ending port for ingress"
  type        = number
}

variable "ingress_cidr_blocks" {
  description = "The CIDR blocks for ingress"
  type        = list(string)
  default     = []
}

variable "egress_protocol" {
  description = "Protocol to be used for egress"
  type        = string
  default     = "tcp"
}

variable "egress_from_port" {
  description = "The starting port for egress"
  type        = number
}

variable "egress_to_port" {
  description = "The ending port for egress"
  type        = number
}

variable "egress_cidr_blocks" {
  description = "The CIDR blocks for egress"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}