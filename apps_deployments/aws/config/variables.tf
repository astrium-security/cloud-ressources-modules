variable "cloudflare_api_token" {
    description = "cloudflare_api_token"
    type        = string
}

variable "cloudflare_account_id" {
  default = "e8b10b5ba49d8ecf809746dee6779b7f"
  type = string
}

variable "cloudflare_zone_id" {
  default = "4319d77718492c29896112b882c5de62"
  type = string
}

variable "internal_domain" {
  default = "platform-factory.internal"
  type = string
}

variable "public_domain" {
  default = "platform-factory.com"
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
    "urw.com",
    "ext.urw.com",
    "syfrah.com",
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

variable "vpc_id" {
    default = "vpc-06fae845f7966f7f1"
    type        = string
}