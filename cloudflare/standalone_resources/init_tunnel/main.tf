#terraform {
#  required_version = ">= 1.5.2"
#    required_providers {
#      cloudflare = {
#        source  = "registry.terraform.io/cloudflare/cloudflare"
#        version = "~> 4.10.0"
#      }
#    }
#}

#data "cloudflare_origin_ca_root_certificate" "origin_ca" {
#  algorithm = "RSA"
#}

#resource "cloudflare_zone_settings_override" "cert-com-settings" {
#  zone_id = var.cloudflare_zone_id

#  settings {
#    tls_1_3                  = "on"
#    automatic_https_rewrites = "on"
#    ssl                      = "strict"
#  }
#}

resource "random_string" "argo_tunnel_password" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric  = true
}

locals {
  encoded_argo_tunnel_password = base64encode(random_string.argo_tunnel_password.result)
}

resource "cloudflare_tunnel" "tunnel" {
  account_id = var.cloudflare_account_id
  name       = "${var.prefix}-${var.infra_environment}-${var.region}"
  secret     = local.encoded_argo_tunnel_password
}