resource "aws_eip" "this" {
  tags = merge(var.common_tags, { Name = "${var.common_prefix}nat-eip" })
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.this.id
  subnet_id     = var.subnet_id
  tags          = merge(var.common_tags, { Name = "${var.common_prefix}natgw" })
} 