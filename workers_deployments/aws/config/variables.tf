variable "cloudflare_api_token" {
    description = "cloudflare_api_token"
    type        = string
}

variable "cloudflare_account_id" {
  type = string
}

variable "cloudflare_zone_id" {
  type = string
}

variable "internal_domain" {
  type = string
}

variable "public_domain" {
  type = string
}

variable "region" {
    description = "region"
    default = "eu-west-3"
    type        = string
}

variable "app_private" {
    description = "app_private"
    type        = bool
    default = false
}

variable "app_name" {
    description = "cloudflare_api_token"
    type        = string
}

variable "app_image" {
    description = "cloudflare_api_token"
    type        = string
}

variable "app_env" {
    description = "app_env"
    type        = string
}

variable "infra_env" {
    description = "infra_env"
    type        = string
    default = "noprod"
}

variable "app_health" {
    description = "app_health path"
    type        = string
  
}

variable "container_port" {
    description = "container_port"
    type        = string
    default = 3000
}

variable "host_port" {
    description = "host_port"
    type        = string
    default = 3000
}

variable "domain_emails_authorization_only" {
  default = [
    "platform-factory.com",
    "urw.com",
    "ext.urw.com",
    "syfrah.com"
  ]
  type = any
}

variable "is_private_app" {
    description = "is_private_app"
    type        = bool
    default = true
}

variable "cloudflare_tunnel_id" {
    description = "cloudflare_tunnel_id"
    type        = string
}

variable "app_cpu_container" {
    description = "cpu"
    type        = string
    default = 256
}

variable "app_ram_container" {
    description = "cpu"
    type        = string
    default = 512
}

variable "is_autoscale" {
    description = "is_autoscale"
    type        = bool
    default = true
}
