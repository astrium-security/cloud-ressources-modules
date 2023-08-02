terraform {
  required_version = ">= 1.5.2"
    required_providers {
      cloudflare = {
        source  = "registry.terraform.io/cloudflare/cloudflare"
        version = "~> 4.10.0"
      }
    }
}

provider "cloudflare" {}

resource "random_id" "secret" {
  byte_length = 32
}

resource "cloudflare_tunnel" "example" {
  account_id = var.cloudflare_account_id
  name       = "${var.prefix}-${var.infra_environment}-${var.region}"
  secret     = base64encode(random_id.secret.b64_url)
}