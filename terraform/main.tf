module "vpc" {
  source       = "./modules/network/vpc"
  cidr_block   = "10.0.0.0/16"
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}

module "subnet_public" {
  source                = "./modules/network/subnet"
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.1.0/24"
  availability_zone     = "ap-northeast-2a"
  map_public_ip_on_launch = true
  name                  = "public-1a"
  common_prefix         = local.common_prefix
  common_tags           = local.common_tags
}

module "igw" {
  source        = "./modules/network/igw"
  vpc_id        = module.vpc.vpc_id
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}

module "natgw" {
  source        = "./modules/network/natgw"
  subnet_id     = module.subnet_public.id
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}

module "subnet_private" {
  source                = "./modules/network/subnet"
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.2.0/24"
  availability_zone     = "ap-northeast-2a"
  map_public_ip_on_launch = false
  name                  = "private-1a"
  common_prefix         = local.common_prefix
  common_tags           = local.common_tags
}

# 퍼블릭 라우팅 테이블
resource "aws_route_table" "public" {
  vpc_id = module.vpc.vpc_id
  tags = merge(local.common_tags, { Name = "${local.common_prefix}public-rtb" })
}

# IGW로 0.0.0.0/0 라우트
resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = module.igw.igw_id
}

# 퍼블릭 서브넷 연결
resource "aws_route_table_association" "public" {
  subnet_id      = module.subnet_public.id
  route_table_id = aws_route_table.public.id
}

# 프라이빗 라우팅 테이블
resource "aws_route_table" "private" {
  vpc_id = module.vpc.vpc_id
  tags = merge(local.common_tags, { Name = "${local.common_prefix}private-rtb" })
}

# NAT GW로 0.0.0.0/0 라우트
resource "aws_route" "private_natgw_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = module.natgw.natgw_id
}

# 프라이빗 서브넷 연결
resource "aws_route_table_association" "private" {
  subnet_id      = module.subnet_private.id
  route_table_id = aws_route_table.private.id
}
