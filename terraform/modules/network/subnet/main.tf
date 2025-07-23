locals {
  # 서브넷을 타입별로 분류
  public_subnets = [for i, subnet in var.subnets : subnet if subnet.map_public_ip_on_launch]
  private_subnets = [for i, subnet in var.subnets : subnet if !subnet.map_public_ip_on_launch]
  
  # 서브넷 이름을 인덱스로 매핑
  subnet_index_map = { for i, subnet in var.subnets : subnet.name => i }
}

resource "aws_subnet" "this" {
  count                     = length(var.subnets)
  vpc_id                    = var.vpc_id
  cidr_block                = var.subnets[count.index].cidr_block
  availability_zone         = var.subnets[count.index].availability_zone
  map_public_ip_on_launch   = var.subnets[count.index].map_public_ip_on_launch
  tags = merge(var.common_tags, {
    Name = "${var.common_prefix}${var.subnets[count.index].name}"
  })
} 