resource "aws_route53_zone" "this" {
  name    = var.domain_name
  comment = "Hosted zone for ${var.domain_name}"

  tags = merge(
    var.common_tags,
    {
      Name = "${var.common_prefix}hosted-zone"
    }
  )

}

