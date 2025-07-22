resource "aws_vpn_gateway" "this" {
  vpc_id = var.vpc_id
  tags   = merge(var.common_tags, { Name = "${var.common_prefix}vgw" })
}

resource "aws_vpn_connection" "this" {
  vpn_gateway_id      = aws_vpn_gateway.this.id
  customer_gateway_id = var.customer_gateway_id
  type                = "ipsec.1"
  static_routes_only  = var.static_routes_only
  tags                = merge(var.common_tags, { Name = "${var.common_prefix}sitetositevpn" })
} 