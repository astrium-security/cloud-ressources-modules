variable "cloudflare_account_id" {
  description = "The ID of the Cloudflare account to use."
  type        = string
}

variable "cloudflare_zone_id" {
  type = string
  default = ""
}

variable "prefix" {
  description = "The prefix to use for naming resources."
  type        = string
}

variable "infra_environment" {
  description = "The infrastructure environment to use (e.g., dev, test, prod)."
  type        = string
}

variable "region" {
  description = "The region in which resources will be created."
  type        = string
}

variable "name" {
  description = "name"
  type        = string
}

variable "platform_domain_public" {
  description = "platform_domain_public"
  type        = string
  default     = "platform-factory.com"
}