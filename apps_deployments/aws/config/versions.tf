terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "5.31.0"
        }
        cloudflare = {
            source  = "registry.terraform.io/cloudflare/cloudflare"
            version = "~> 4.20"
        }
    }
    cloud {
      organization = "syfrah"
      workspaces {
        name = "_REPLACED_VALUE_BY_SED_"
      }
    }
}

provider "aws" {
  region = "eu-west-3"
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
