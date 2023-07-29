variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "prefix" {
  description = "Prefix to use for all resources"
  type        = string
}

variable "infra_environment" {
  description = "The infrastructure environment"
  type        = string
}
