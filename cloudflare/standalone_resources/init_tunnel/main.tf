terraform {
  required_version = ">= 1.5.2"
    required_providers {
      cloudflare = {
        source  = "registry.terraform.io/cloudflare/cloudflare"
        version = "~> 4.10.0"
      }
    }
}


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