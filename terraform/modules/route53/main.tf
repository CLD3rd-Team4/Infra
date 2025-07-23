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
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

