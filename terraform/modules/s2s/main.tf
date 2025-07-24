

resource "aws_customer_gateway" "this" {
  bgp_asn    = var.on_prem_bgp_asn
  ip_address = var.on_prem_public_ip
  type       = "ipsec.1"

  tags = merge(var.s2s_vpn_tags, {
    Name = "${var.s2s_vpn_tags["Name"]}-cgw"
  })

}

resource "aws_vpn_gateway" "this" {
  vpc_id = var.vpc_id

  tags = merge(var.s2s_vpn_tags, {
    Name = "${var.s2s_vpn_tags["Name"]}-vgw"
  })
}

resource "aws_vpn_connection" "this" {
  customer_gateway_id = aws_customer_gateway.this.id
  vpn_gateway_id      = aws_vpn_gateway.this.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = merge(var.s2s_vpn_tags, {
    Name = "${var.s2s_vpn_tags["Name"]}-vpn"
  })
}

# 기존 private route table
resource "aws_route" "this" {
  route_table_id         = var.route_table_id  
  destination_cidr_block = var.on_prem_cidr_block
  gateway_id             = aws_vpn_gateway.this.id
}
