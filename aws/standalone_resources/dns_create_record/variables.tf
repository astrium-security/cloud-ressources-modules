variable "route53_zone_id" {
  description = "The ID of the hosted zone to contain this record."
  type        = any
}

variable "app_name" {
  description = "The name of the application."
  type        = string
}

variable "app_env" {
  description = "The environment of the application (e.g., dev, staging, prod)."
  type        = string
}

variable "prefix" {
  description = "The prefix of the DNS record."
  type        = string
}

variable "region" {
  description = "The region of the AWS resources."
  type        = string
}

variable "type_record" {
  description = "The type of the DNS record."
  type        = string
}

variable "targets" {
  description = "A list of IP addresses or domains that this record will resolve to."
  type        = any
}

variable "cloudflare_zone_id" {
  description = "The ID of the hosted zone to contain this record in Cloudflare."
  type        = string
}

variable "cloudflare_tunnel" {
  description = "The object of the hosted zone to contain this record in Cloudflare."
  type        = any
}
