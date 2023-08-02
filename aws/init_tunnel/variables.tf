variable "public_subnets" {
  description = "List of public subnets in your VPC"
  type        = any
}

variable "cloudflare_token_64" {
  type = string
  default = ""
}

variable "prefix" {
  description = "Prefix used to name the security group"
  type        = string
}

variable "infra_environment" {
  description = "The infrastructure environment"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC where the security group is to be created"
  type        = string
}
