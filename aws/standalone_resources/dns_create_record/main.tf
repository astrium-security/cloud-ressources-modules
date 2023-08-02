

resource "aws_route53_record" "internal_record" {
  zone_id = var.route53_zone_id.id
  name    = "${var.app_name}.${var.app_env}.${var.prefix}.${var.region}.${var.route53_zone_id.name}"
  type    = var.type_record
  ttl     = 300
  records = var.targets
}

#resource "cloudflare_record" "example" {
#  zone_id = var.cloudflare_zone_id
#  name    = "${var.app_name}.${var.app_env}.${var.prefix}.${var.region}.${var.cloudflare_zone_id.name}"
#  value   = var.targets
#  type    = var.type_record
#  ttl     = 3600
#}