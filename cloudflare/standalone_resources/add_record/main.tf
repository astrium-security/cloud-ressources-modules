terraform {
    required_providers {
      cloudflare = {
        source  = "registry.terraform.io/cloudflare/cloudflare"
        version = "4.20.0"
      }
    }
}

resource "cloudflare_record" "this" {
  zone_id   =  var.zone_id
  name      =  var.name
  ttl       =  var.ttl
  type      =  var.type
  priority  =  var.type == "MX" ? var.priority : null
  proxied   =  var.proxied
  value     =  var.value
}