resource "cloudflare_access_application" "apps" {
  zone_id = var.cloudflare_zone_id
  name                      = var.name
  domain                    = "*.${var.infra_environment}.${var.prefix}.${var.region}.${var.platform_domain_public}"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = false
}

resource "cloudflare_access_policy" "policies" {
  application_id = cloudflare_access_application.apps.id
  zone_id        = var.cloudflare_zone_id
  name           = "Internal Policy"
  precedence     = "1"
  decision       = "allow"

  include {
    email_domain = var.email_domain
  }
}