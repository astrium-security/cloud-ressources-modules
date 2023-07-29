data "aws_route53_zone" "selected" {
  zone_id         =  var.route53_zone_id
}

resource "aws_acm_certificate" "cert_public" {
  domain_name       = data.aws_route53_zone.selected.name
  validation_method = "DNS"

  subject_alternative_names = ["*.${data.aws_route53_zone.selected.name}"]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "cert_validation_public" {
    for_each = {
        for dvo in aws_acm_certificate.cert_public.domain_validation_options : dvo.domain_name => {
        name   = dvo.resource_record_name
        record = dvo.resource_record_value
        type   = dvo.resource_record_type
        }
        if length(regexall("\\*\\..+", dvo.domain_name)) > 0
    }

    name    = each.value.name
    type    = each.value.type
    zone_id = var.route53_zone_id
    records = [each.value.record]
    ttl     = 60
}

resource "aws_acm_certificate_validation" "cert_validation_public" {
  certificate_arn         = aws_acm_certificate.cert_public.arn
  validation_record_fqdns = [for record in aws_acm_certificate.cert_public.domain_validation_options : record.resource_record_name]
}
