variable "prefix" {
  description = "Prefix to use for all resources"
  type        = string
}

variable "infra_environment" {
  description = "The infrastructure environment"
  type        = string
}

variable "cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnets" {
  description = "A list of public subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "private_subnets" {
  description = "A list of private subnet CIDR blocks"
  type        = list(string)
  default     = []
}

variable "availability_zones" {
  description = "A list of Availability Zones in the Region"
  type        = list(string)
  default     = []
}
