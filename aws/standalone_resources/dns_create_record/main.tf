
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
  value   = var.cloudflare_tunnel.tunnel_cname
  type    = var.type_record
  proxied = true
  allow_overwrite = true
  ttl     = 1
  provisioner "local-exec" {
    interpreter = ["/usr/bin/python3"]
    command = <<EOF
import requests
import sys
import json
import os

url = "https://api.cloudflare.com/client/v4/accounts/${data.cloudflare_zone.domain.account_id}/cfd_tunnel/${var.cloudflare_tunnel.id}/configurations"

headers = {
  'Authorization': 'Bearer ' + os.getenv('CLOUDFLARE_API_TOKEN'),
  'Content-Type': 'application/json'
}

response = requests.request("GET", url, headers=headers)
response = json.loads(response.text)

array = response["result"]["config"]["ingress"]

# Check if service exists already
service_exists = False
for item in array:
    if 'hostname' in item and item['hostname'] == '${var.app_name}.${var.app_env}.${var.prefix}.${var.region}.${data.cloudflare_zone.domain.name}':
        item['service'] = ${var.targets[0]}
        service_exists = True
        break

# If service does not exist, append new configuration
if not service_exists:
    array.insert(0, {'service': ${var.targets[0]}, 'hostname': '${var.app_name}.${var.app_env}.${var.prefix}.${var.region}.${data.cloudflare_zone.domain.name}'})

payload = json.dumps({
  "config": {
    "originRequest": {
      "connectTimeout": 10
    },
    "ingress": array
  }
})

response = requests.request("PUT", url, headers=headers, data=payload)
EOF
  }
  provisioner "local-exec" {
    command = <<EOF
python3 ingress.py ${var.app_name}.${var.app_env}.${var.prefix}.${var.region}.${data.cloudflare_zone.domain.name} http://${var.targets[0]}
EOF
  }
}

# Add ingress

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