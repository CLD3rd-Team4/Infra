resource "aws_internet_gateway" "this" {
  vpc_id = var.vpc_id
  tags   = merge(var.common_tags, { Name = "${var.common_prefix}igw" })
} 