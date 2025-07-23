resource "aws_ec2_client_vpn_endpoint" "this" {
  description            = var.description
  server_certificate_arn = var.server_certificate_arn
  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.root_certificate_chain_arn
  }
  client_cidr_block      = var.client_cidr_block
  vpc_id                 = var.vpc_id
  tags                   = merge(var.common_tags, { Name = "${var.common_prefix}clientvpn" })
} 