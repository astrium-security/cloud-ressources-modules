variable "name" {
    description = "The name of the RDS instance"
    type        = string
}

variable "vpc" {
    description = "value of vpc"
    type        = object({
        vpc_id = string
        subnets = any
    })
    default = {
      vpc_id = "vpc-0a52c88a170901671"
      subnets = [
        {
            id = "subnet-090b70a700c6e2b80"
            cidr_block = "172.31.0.0/20"
        }
      ]
    }
}

variable "min_acu_capacity" {
    description = "min_acu_capacity"
    type        = number
    default = 1
}

variable "max_acu_capacity" {
    description = "max_acu_capacity"
    type        = number
    default = 1
}

variable "min_capacity" {
    description = "min_capacity"
    type        = number
    default = 1
}

variable "max_capacity" {
    description = "min_capacity"
    type        = number
    default = 1
}

variable "business_hours_only" {
    description = "business_hours_only"
    type        = bool
    default = true
}