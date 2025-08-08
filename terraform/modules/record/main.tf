resource "aws_route53_record" "a_record" {
  count   = var.record_type == "A" ? 1 : 0
  zone_id = var.zone_id
  name    = var.name
  type    = "A"

  alias {
    name                   = var.alias_name
    zone_id                = var.alias_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}

resource "aws_route53_record" "txt_record" {
  count   = var.record_type == "TXT" ? 1 : 0
  zone_id = var.zone_id
  name    = var.name
  type    = "TXT"
  ttl     = var.ttl
  records = var.records
}


resource "aws_route53_record" "cname_record" {
  count   = var.record_type == "CNAME" ? 1 : 0
  zone_id = var.zone_id
  name    = var.name
  type    = "CNAME"
  ttl     = var.ttl
  records = var.records
}