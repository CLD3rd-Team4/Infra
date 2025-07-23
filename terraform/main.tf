module "vpc" {
  source       = "./modules/network/vpc"
  cidr_block   = "10.0.0.0/16"
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}

module "igw" {
  source        = "./modules/network/igw"
  vpc_id        = module.vpc.vpc_id
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}

module "natgw" {
  source        = "./modules/network/natgw"
  subnet_id     = module.subnet_public_1a.id
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}

# 퍼블릭 서브넷 2개
module "subnet_public_1a" {
  source                = "./modules/network/subnet"
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.1.0/24"
  availability_zone     = "ap-northeast-2a"
  map_public_ip_on_launch = true
  name                  = "public-1a"
  common_prefix         = local.common_prefix
  common_tags           = local.common_tags
}

module "subnet_public_2c" {
  source                = "./modules/network/subnet"
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.2.0/24"
  availability_zone     = "ap-northeast-2c"
  map_public_ip_on_launch = true
  name                  = "public-2c"
  common_prefix         = local.common_prefix
  common_tags           = local.common_tags
}

# 프라이빗 서브넷 4개
module "subnet_private_1a_1" {
  source                = "./modules/network/subnet"
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.10.0/24"
  availability_zone     = "ap-northeast-2a"
  map_public_ip_on_launch = false
  name                  = "private-1a-1"
  common_prefix         = local.common_prefix
  common_tags           = local.common_tags
}
module "subnet_private_1a_2" {
  source                = "./modules/network/subnet"
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.11.0/24"
  availability_zone     = "ap-northeast-2a"
  map_public_ip_on_launch = false
  name                  = "private-1a-2"
  common_prefix         = local.common_prefix
  common_tags           = local.common_tags
}
module "subnet_private_2c_1" {
  source                = "./modules/network/subnet"
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.12.0/24"
  availability_zone     = "ap-northeast-2c"
  map_public_ip_on_launch = false
  name                  = "private-2c-1"
  common_prefix         = local.common_prefix
  common_tags           = local.common_tags
}
module "subnet_private_2c_2" {
  source                = "./modules/network/subnet"
  vpc_id                = module.vpc.vpc_id
  cidr_block            = "10.0.13.0/24"
  availability_zone     = "ap-northeast-2c"
  map_public_ip_on_launch = false
  name                  = "private-2c-2"
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

# 퍼블릭 서브넷 2개 연결
resource "aws_route_table_association" "public_1a" {
  subnet_id      = module.subnet_public_1a.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_2c" {
  subnet_id      = module.subnet_public_2c.id
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

# 프라이빗 서브넷 4개 연결
resource "aws_route_table_association" "private_1a_1" {
  subnet_id      = module.subnet_private_1a_1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private_1a_2" {
  subnet_id      = module.subnet_private_1a_2.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private_2c_1" {
  subnet_id      = module.subnet_private_2c_1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private_2c_2" {
  subnet_id      = module.subnet_private_2c_2.id
  route_table_id = aws_route_table.private.id
}
