resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  tags = merge(
    var.common_tags,
    {
      Name = "${var.common_prefix}${var.name}"
    }
  )
}

resource "aws_route" "default" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.target_type == "igw" ? var.default_route_target_id : null
  nat_gateway_id         = var.target_type == "natgw" ? var.default_route_target_id : null
}

resource "aws_route_table_association" "subnet_associations" {
  count = length(var.subnet_ids)
  
  subnet_id      = var.subnet_ids[count.index]
  route_table_id = aws_route_table.this.id
}
