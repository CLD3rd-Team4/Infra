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

# 퍼블릭 서브넷 (3개 - 각각 다른 가용 영역)
module "public_subnets" {
  source        = "./modules/network/subnet"
  vpc_id        = module.vpc.vpc_id
  subnet_type   = "public"
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
  subnets = [
    { name = "public-1", cidr_block = "10.0.4.0/24", availability_zone = "ap-northeast-2a" },
    { name = "public-2", cidr_block = "10.0.5.0/24", availability_zone = "ap-northeast-2b" },
    { name = "public-3", cidr_block = "10.0.6.0/24", availability_zone = "ap-northeast-2c" }
  ]
}

# 프라이빗 서브넷 (3개 - 각각 다른 가용 영역)
module "private_subnets" {
  source        = "./modules/network/subnet"
  vpc_id        = module.vpc.vpc_id
  subnet_type   = "private"
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
  subnets = [
    { name = "private-1", cidr_block = "10.0.14.0/24", availability_zone = "ap-northeast-2a" },
    { name = "private-2", cidr_block = "10.0.15.0/24", availability_zone = "ap-northeast-2b" },
    { name = "private-3", cidr_block = "10.0.16.0/24", availability_zone = "ap-northeast-2c" }
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

# Private CA 모듈
module "privateca" {
  source        = "./modules/network/privateca"
  common_prefix = local.common_prefix
  common_tags   = local.common_tags
}

# Client VPN 모듈
module "client_vpn" {
  source                    = "./modules/network/clientvpn"
  vpc_id                    = module.vpc.vpc_id
  vpc_cidr                 = module.vpc.vpc_cidr
  subnet_ids               = module.private_subnets.subnet_ids
  client_cidr_block        = "172.16.0.0/22"  # VPC CIDR과 겹치지 않는 범위
  server_certificate_arn    = module.privateca.server_certificate_arn
  root_certificate_chain_arn = module.privateca.client_certificate_arn
  common_prefix            = local.common_prefix
  common_tags              = local.common_tags
  description             = "${local.common_prefix} Client VPN"
}
