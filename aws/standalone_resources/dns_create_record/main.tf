
terraform {
  required_version = ">= 1.5.2"
    required_providers {
      cloudflare = {
        source  = "registry.terraform.io/cloudflare/cloudflare"
        version = "~> 4.10.0"
      }
    }
}

data "cloudflare_zone" "domain" {
  zone_id = var.cloudflare_zone_id
}

resource "aws_route53_record" "internal_record" {
  zone_id = var.route53_zone_id.id
  name    = "${var.app_name}.${var.app_env}.${var.prefix}.${var.region}.${var.route53_zone_id.name}"
  type    = var.type_record
  ttl     = 300
  records = var.targets
}

resource "cloudflare_record" "new_record" {
  zone_id = var.cloudflare_zone_id
  name    = "${var.app_name}.${var.app_env}.${var.prefix}.${var.region}.${data.cloudflare_zone.domain.name}"
  value   = var.cloudflare_tunnel_cname
  type    = var.type_record
  proxied = true
  allow_overwrite = true
  ttl     = 1
}

data "cloudflare_origin_ca_root_certificate" "origin_ca" {
  algorithm = "RSA"
}

resource "tls_private_key" "cert" {
  algorithm = "RSA"
}

resource "tls_cert_request" "cert" {
  private_key_pem = tls_private_key.cert.private_key_pem
}

resource "cloudflare_origin_ca_certificate" "cert" {
    csr                = tls_cert_request.cert.cert_request_pem

    hostnames          = [cloudflare_record.new_record.name]

    request_type       = "origin-rsa"
    requested_validity = 5475    
}

#resource "cloudflare_certificate_pack" "cert" {
#  zone_id = var.cloudflare_zone_id
#  type                   = "advanced"
#  hosts                  = cloudflare_origin_ca_certificate.cert.hostnames
#  validation_method      = "txt"
#  validity_days          = 90
#  certificate_authority   = "digicert"
#  cloudflare_branding    = false
#  wait_for_active_status = true

#  lifecycle {
#    create_before_destroy = true
#  }
#}