resource "cloudflare_access_application" "apps" {
  count = var.app_private ? 1 : 0
  zone_id = var.cloudflare_zone_id
  name                      = var.app_env != "prod" ?  "${var.app_name}-${var.app_env}.${var.region}.${var.public_domain}" : "${var.app_name}.${var.public_domain}"
  domain                    = var.app_env != "prod" ?  "${var.app_name}-${var.app_env}.${var.region}.${var.public_domain}" : "${var.app_name}.${var.public_domain}"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = false
}

resource "cloudflare_access_policy" "policies" {
  count = var.app_private ? 1 : 0
  application_id = cloudflare_access_application.apps[0].id
  zone_id        = var.cloudflare_zone_id
  name           = "Internal Policy"
  precedence     = "1"
  decision       = "allow"

  include {
    email_domain = var.domain_emails_authorization_only
  }
}

data "aws_ssm_parameter" "get_ingress" {
  name = "/infra/ingress/INGRESS_CONFIG"
}

locals {
  current_ingress = jsondecode(data.aws_ssm_parameter.get_ingress.value)

  intermediate_config = [
    for ingress in local.current_ingress.config[0].ingress_rule : 
      ingress.hostname != "" ? 
        (ingress.hostname == local.dynamic_ingress_rules.hostname ? local.dynamic_ingress_rules : ingress) 
      : null
  ]

  non_null_intermediate_config = [for ingress in local.intermediate_config : ingress if ingress != null]

  exists_dynamic_ingress_rules = contains([for ingress in local.non_null_intermediate_config : ingress.hostname], local.dynamic_ingress_rules.hostname)

  dynamic_ingress_rules_as_list = [local.dynamic_ingress_rules]

  updated_config = local.exists_dynamic_ingress_rules ? local.non_null_intermediate_config : concat(local.non_null_intermediate_config, local.dynamic_ingress_rules_as_list)

  final_config = nonsensitive([for ingress in local.updated_config : ingress if ingress != null])
}

resource "cloudflare_tunnel_config" "this" {
  account_id = var.cloudflare_account_id
  tunnel_id  = var.cloudflare_tunnel_id

  config {
    dynamic "ingress_rule" {
      # Utilisez une carte avec des clés uniques basées sur un attribut distinctif
      for_each = { for ingress in local.final_config : ingress.hostname => ingress }

      content {
        hostname = ingress_rule.value.hostname
        path     = ingress_rule.value.path
        service  = ingress_rule.value.service
      }
    }

    ingress_rule {
      service = "http://0.0.0.0:8080"
    }
  }
}

module "ingress_config" {
  source      = "../../../aws/standalone_resources/ssm_parameter_store"
  type        = "String"
  description = "ingress"  
  data_value   = jsonencode(cloudflare_tunnel_config.this)
  infra_or_app = "infra"
  component   = "ingress"
  name        = "INGRESS_CONFIG"
}

data "cloudflare_origin_ca_root_certificate" "origin_ca" {
  algorithm = "RSA"
}

resource "cloudflare_zone_settings_override" "cert-com-settings" {
  zone_id = var.cloudflare_zone_id

  settings {
    tls_1_3                  = "on"
    automatic_https_rewrites = "on"
    ssl                      = "strict"
  }
}

resource "tls_private_key" "cert" {
  algorithm = "RSA"
}

resource "tls_cert_request" "cert" {
  private_key_pem = tls_private_key.cert.private_key_pem
}

resource "cloudflare_origin_ca_certificate" "cert" {
    csr                = tls_cert_request.cert.cert_request_pem

    hostnames          = [ 
      var.app_env != "prod" ?  "${var.app_name}-${var.app_env}.${var.region}.${var.public_domain}" : "${var.app_name}.${var.public_domain}",
      "${var.public_domain}"
    ]

    request_type       = "origin-rsa"
    requested_validity = 5475    
}

resource "cloudflare_certificate_pack" "this" {
  zone_id = var.cloudflare_zone_id
  type                   = "advanced"
  hosts                  = cloudflare_origin_ca_certificate.cert.hostnames
  validation_method      = "txt"
  validity_days          = 90
  certificate_authority   = "google"
  cloudflare_branding    = false
  wait_for_active_status = true

  lifecycle {
    create_before_destroy = true
  }
}