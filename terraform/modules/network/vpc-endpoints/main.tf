resource "aws_vpc_endpoint" "this" {
  for_each = { for svc in var.services : svc.name => svc }

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.${each.value.name}"
  vpc_endpoint_type   = each.value.type

  route_table_ids     = each.value.type == "Gateway" ? var.route_table_ids : null
  subnet_ids          = each.value.type == "Interface" ? var.subnet_ids : null
  security_group_ids  = each.value.type == "Interface" ? var.security_group_ids : null
  private_dns_enabled = each.value.type == "Interface" ? each.value.private_dns_enabled : null

  tags = merge(
    var.common_tags,
    {
      Name = "${var.common_prefix}${each.value.name}-vpc-endpoint"
    }
  )
}
