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

# 퍼블릭 서브넷 (2개)
module "public_subnets" {
  source        = "./modules/network/public_subnet"
  vpc_id        = module.vpc.vpc_id
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
  subnets = [
    { name = "public-1a", cidr_block = "10.0.1.0/24", availability_zone = "ap-northeast-2a" },
    { name = "public-2c", cidr_block = "10.0.2.0/24", availability_zone = "ap-northeast-2c" }
  ]
}

# 프라이빗 서브넷 (4개)
module "private_subnets" {
  source        = "./modules/network/private_subnet"
  vpc_id        = module.vpc.vpc_id
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
  subnets = [
    { name = "private-1a-1", cidr_block = "10.0.10.0/24", availability_zone = "ap-northeast-2a" },
    { name = "private-1a-2", cidr_block = "10.0.11.0/24", availability_zone = "ap-northeast-2a" },
    { name = "private-2c-1", cidr_block = "10.0.12.0/24", availability_zone = "ap-northeast-2c" },
    { name = "private-2c-2", cidr_block = "10.0.13.0/24", availability_zone = "ap-northeast-2c" }
  ]
}

module "natgw" {
  source        = "./modules/network/natgw"
  subnet_id     = module.public_subnets.subnet_ids[0]
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}

# 퍼블릭 라우팅 테이블 모듈
module "public_route_table" {
  source                = "./modules/network/route_table"
  vpc_id                = module.vpc.vpc_id
  name                  = "public-rtb"
  default_route_target_id = module.igw.igw_id
  target_type           = "igw"
  subnet_ids            = module.public_subnets.subnet_ids
  common_prefix         = local.common_prefix
  common_tags           = local.common_tags
}

# 프라이빗 라우팅 테이블 모듈
module "private_route_table" {
  source                = "./modules/network/route_table"
  vpc_id                = module.vpc.vpc_id
  name                  = "private-rtb"
  default_route_target_id = module.natgw.natgw_id
  target_type           = "natgw"
  subnet_ids            = module.private_subnets.subnet_ids
  common_prefix         = local.common_prefix
  common_tags           = local.common_tags
}
