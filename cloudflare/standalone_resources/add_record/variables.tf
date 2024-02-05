variable "zone_id" {
  description = "The zone id"
  type        = string
}

variable "name" {
  description = "The name of the record"
  type        = string
}

variable "ttl" {
  description = "The TTL of the record"
  type        = number
}

variable "type" {
  description = "The type of the record"
  type        = string
}

variable "proxied" {
  description = "Whether the record is proxied"
  type        = bool
}

variable "value" {
  description = "The value of the record"
  type        = string
}

variable "priority" {
  description = "The value of the priority record"
  type        = string
}