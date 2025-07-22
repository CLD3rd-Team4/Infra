locals {
  common_prefix = "mapzip-${terraform.workspace}-"
  common_tags = {
    Environment = terraform.workspace
    Project     = "mapzip"
    ManagedBy   = "Terraform"
  }
}

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
