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
}

variable "min_acu_capacity" {
    description = "min_acu_capacity"
    type        = number
}

variable "max_acu_capacity" {
    description = "max_acu_capacity"
    type        = number
}

variable "min_capacity" {
    description = "min_capacity"
    type        = number
}

variable "max_capacity" {
    description = "min_capacity"
    type        = number
}

variable "business_hours_only" {
    description = "business_hours_only"
    type        = bool
}