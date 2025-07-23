resource "aws_subnet" "this" {
  count = length(var.subnets)

  vpc_id                  = var.vpc_id
  cidr_block              = var.subnets[count.index].cidr_block
  availability_zone       = var.subnets[count.index].availability_zone
  map_public_ip_on_launch = false

  tags = merge(
    var.common_tags,
    {
      Name = "${var.common_prefix}${var.subnets[count.index].name}"
      Type = "private"
    }
  )
}
