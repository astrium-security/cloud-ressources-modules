variable "name" {
  description = "The name of the redis cluster"
  type        = string
}


variable "infra_environment" {
  description = "The infrastructure environment"
  type        = string
}

variable "customer_prefix" {
  description = "The customer prefix"
  type        = string
}


variable "num_cache_clusters" {
  description = "The number of cache clusters"
  type        = number
}

variable "node_type" {
  description = "The node type"
  type        = string  
}

variable "replicas_per_node_group" {
  description = "The number of replicas per node group"
  type        = number
}

variable "num_node_groups" {
  description = "The number of node groups"
  type        = number 
}

variable "snapshot_retention_limit" {
  description = "The snapshot retention limit"
  type        = number
}

variable "engine_version" {
  description = "The engine version"
  type        = string
}

variable "family" {
  description = "The family"
  type        = string
}

variable "description" {
  description = "The description"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet ids"
  type        = any
}

variable "vpc_id" {
  description = "The vpc id"
  type        = string
}
