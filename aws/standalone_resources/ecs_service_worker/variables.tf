variable "prefix" {
  description = "The prefix to use for all resources"
  type        = string
}

variable "container_name" {
  description = "The name of the container"
  type        = string
}

variable "app_environment" {
  description = "The application environment"
  type        = string
}

variable "cluster" {
  description = "The ID of the ECS cluster"
  type        = any
}

variable "task_definition_arn" {
  description = "The ARN of the task definition"
  type        = string
}

variable "desired_count" {
  description = "The desired number of instances of the task definition to keep running on the service"
  type        = number
}

variable "launch_type" {
  description = "The launch type on which to run your service"
  type        = string
  default     = "EC2"
}

variable "scheduling_strategy" {
  description = "The scheduling strategy to use for the service"
  type        = string
  default     = "REPLICA"
}

variable "force_new_deployment" {
  description = "Forces a new deployment of the service"
  type        = bool
  default     = false
}

variable "security_groups" {
  description = "The list of security group IDs for the service"
  type        = list(any)
}

variable "public_subnet" {
  description = "List of public subnets"
  type        = list(any)
}

variable "container_port" {
  description = "The port on which the container is listening"
  type        = number
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
